from flask import Flask, session, request
from flask_socketio import SocketIO, emit, join_room, leave_room, close_room
from ..transcriber import Transcriber
import threading
import random
import string
from ..model.conversation import Conversation, ConversationMessage
from ..model.user import User
from ..controllers.auth import get_user

"""
  Details of SocketIO exchanges:
  To start the process, Client sends `transcription_init`
  - We send back `transcription_id`
  
  Client send `transcription_start`
  - We start the transcriber

  Client send `transcribe_data`
  - We transcribe it

  Client sends `transcription_stop`
  - We stop the trancriber

  Client send `transcription_destroy`
  - We clean up, forget tsid
"""

transcriptionSessions = {}


def init_app(app: Flask, session: session, socketio: SocketIO):

  @app.route("/api/conversation/<conv>", methods=["DELETE"])
  def delete_msg(conv):
    data = request.json
    try:
      user: User = get_user(data["jwt"])
    except Exception as e:
      print("Err on JWT", jwt, e)
      return {
        "status": "fail"
      }

    convs = Conversation.objects(id=conv, owner=user)
    if not convs.count():
      return {
        "status": "fail"
      }
    
    convs[0].delete()
    return {
      "status": "success"
    }

  @app.route("/api/conv-messages/<conv>", methods=["POST"])
  def get_messages(conv):
    data = request.json
    try:
      user: User = get_user(data["jwt"])
    except Exception as e:
      print("Err on JWT", jwt, e)
      return {
        "status": "fail"
      }
    
    convs = Conversation.objects(id=conv, owner=user)
    if not convs.count():
      return {
        "status": "fail"
      }
    
    return {
      "status": "success",
      "data": [{
        "txt": x.message,
        "timestamp": x.timestamp,
        "owner": x.owner.email,
        "full_name": x.owner.name
      } for x in convs[0].messages]
    }

  @app.route("/api/conversations", methods=["POST"])
  def get_conversations():
    data = request.json
    try:
      user: User = get_user(data["jwt"])
    except Exception as e:
      print("Err on JWT", jwt, e)
      return {
        "status": "fail"
      }

    convs = Conversation.objects(owner=user)
    ret = []
    for c in convs:
      if not len(c.messages):
        # lets take this opportunity to delete those empty guys :D
        c.delete()
        continue
      ret.append({
        "id": str(c.id),
        "member_count": len(c.members),
        "timestamp": c.messages[0].timestamp,
        "msg_count": len(c.messages),
        "last_message": c.messages[-1].message
      })

    ret.reverse()
    return {
      "status": "success",
      "data": ret
    }

  @socketio.on("transcription_init")
  def tr_init(jwt=None):
    try:
      user: User = get_user(jwt)
    except Exception as e:
      print("Err on JWT", jwt, e)
      return
    conv = make_conversation(user)
    tsid = str(conv.id)
    sid = request.sid
    print("TR INIT", tsid, "Socket: ", sid)

    transcriptionSessions[tsid] = {
        "conv": conv,
        "tsid": tsid,
        sid: {
            "user": user,
            "is_owner": 1,
            "transcriber": Transcriber(sid, tsid),
        },
        "transcripts": [],
        "participants": set([sid])
    }
    join_room(tsid)
    emit("transcription_id", tsid)

  def inform_participants(tsid):
    if tsid not in transcriptionSessions:
      return

    s = transcriptionSessions[tsid]
    emit("transcription_participants", [
         {"sid": _sid, "full_name": s[_sid]["full_name"]} for _sid in s["participants"]])

  @socketio.on("transcription_leave")
  def tr_leave(tsid):
    sid = request.sid

    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    if sid not in transcriptionSessions[tsid]["participants"]:
      emit("not-a-member")
      return

    if transcriptionSessions[tsid][sid]:
      transcriptionSessions[tsid][sid]["transcriber"].stop()
      del transcriptionSessions[tsid][sid]
    transcriptionSessions[tsid]["participants"].remove(sid)
    inform_participants(tsid)

  @socketio.on("transcription_join")
  def tr_join(tsid, jwt):
    try:
      user: User = get_user(jwt)
    except:
      return
    sid = request.sid

    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    transcriptionSessions[tsid][sid] = {
        "user": user,
        "full_name": full_name,
        "is_owner": 0,
        "transcriber": Transcriber(sid, tsid)
    }
    transcriptionSessions[tsid]["participants"].add(sid)
    join_room(tsid)
    inform_participants(tsid)

  @socketio.on("transcription_start")
  def tr_start(tsid, language):
    sid = request.sid
    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    if sid not in transcriptionSessions[tsid]:
      emit("invalid-sid-doesnt-belong-to-tsid")
      return

    language_map = {
        "English": "en-IN",
        "Hindi": "hi-IN",
        "Malayalam": "ml-IN",
        "Telugu": "te-IN",
        "Tamil": "ta-IN"
    }
    l_code = language_map.get(language) or "en-IN"
    print("Active Language: ", l_code)

    tr: Transcriber = transcriptionSessions[tsid][sid].get("transcriber")
    tr.set_language(l_code)
    t = threading.Thread(target=tr.start)
    t.start()

  @socketio.on("transcribe_data")
  def tr_data(tsid, data):
    sid = request.sid
    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    if sid not in transcriptionSessions[tsid]:
      emit("invalid-sid-doesnt-belong-to-tsid")
      return

    tr: Transcriber = transcriptionSessions[tsid][sid].get("transcriber")
    # [{is_final: bool, txt: string, tid: string}]
    merge_transcripts(tsid=tsid, sid=sid)
    emit("transcripts", transcriptionSessions[tsid]["transcripts"], room=tsid)
    tr.fill_data(data)

  def merge_transcripts(tsid, sid):
    local_transcripts = list(
        transcriptionSessions[tsid][sid]["transcriber"].transcripts)
    i = len(local_transcripts)
    if not i:
      return

    session_transcripts = transcriptionSessions[tsid]["transcripts"]
    while i > 0:
      tr_l = local_transcripts[i-1]
      tr_l["full_name"] = transcriptionSessions[tsid][sid]["user"]["name"]
      tr_l["sid"] = sid

      j = len(session_transcripts)
      while j > 0:
        tr_s = session_transcripts[j-1]
        if tr_s["timestamp"] >= tr_l["timestamp"]:
          break
        j -= 1

      if j > 0 and session_transcripts[j-1]["tid"] == tr_l["tid"]:
        break

      session_transcripts.insert(j, tr_l)
      i -= 1

    transcriptionSessions[tsid]["transcripts"] = sorted(
        transcriptionSessions[tsid]["transcripts"], key=lambda x: x["timestamp"])

  @socketio.on("transcription_stop")
  def tr_stop(tsid):
    sid = request.sid
    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    if sid not in transcriptionSessions[tsid]:
      emit("invalid-sid-doesnt-belong-to-tsid")
      return

    tr: Transcriber = transcriptionSessions[tsid][sid].get("transcriber")
    print(transcriptionSessions[tsid].get("transcripts"))
    tr.stop()


  @socketio.on("transcription_save")
  def tr_destroy(tsid):
    sid = request.sid
    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    if sid not in transcriptionSessions[tsid]:
      emit("invalid-sid-doesnt-belong-to-tsid")
      return

    if transcriptionSessions[tsid][sid].get("is_owner") != 1:
      emit("invalid-owner-sid-can-only-save")
      return

    conv: Conversation = transcriptionSessions[tsid]["conv"]
    transcripts = transcriptionSessions[tsid]["transcripts"]

    for tr in transcripts:
      if "saved" not in tr:
        tr["saved"] = 1
        conv.messages.append(ConversationMessage(
          timestamp=tr["timestamp"],
          message=tr["txt"],
          owner=transcriptionSessions[tsid][tr["sid"]]["user"]
        ))
    print("tr_save", conv.id)
    conv.save()

  @socketio.on("transcription_destroy")
  def tr_destroy(tsid):
    sid = request.sid
    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    if sid not in transcriptionSessions[tsid]:
      emit("invalid-sid-doesnt-belong-to-tsid")
      return

    if transcriptionSessions[tsid][sid].get("is_owner") != 1:
      emit("invalid-owner-sid-can-only-destroy")
      return

    for k in transcriptionSessions[tsid].keys():
      if not isinstance(transcriptionSessions[tsid][k], dict):
        continue
      tr: Transciber = transcriptionSessions[tsid][k].get("transcriber", None)
      if not tr:
        continue
      tr.stop()

    transcriptionSessions[tsid] = None
    close_room(tsid)


def make_conversation(user: User):
  c = Conversation(owner=user, members=[user], messages=[])
  c.save()
  return c
