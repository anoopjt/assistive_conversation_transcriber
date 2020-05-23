from flask import Flask, session, request
from flask_socketio import SocketIO, emit, join_room, leave_room, close_room
from ..transcriber import Transcriber
import threading
import random
import string

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

  @socketio.on("transcription_init")
  def tr_init(full_name="John"):
    tsid = ''.join(random.choice(string.ascii_uppercase + string.digits)
                   for _ in range(30))
    sid = request.sid

    transcriptionSessions[tsid] = {
        "tsid": tsid,
        sid: {
            "full_name": full_name,
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
  def tr_join(tsid, full_name="Doe"):
    sid = request.sid

    if tsid not in transcriptionSessions:
      emit("invalid-tsid")
      return

    transcriptionSessions[tsid][sid] = {
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
    local_transcripts = list(transcriptionSessions[tsid][sid]["transcriber"].transcripts)
    i = len(local_transcripts)
    if not i:
      return
    
    session_transcripts = transcriptionSessions[tsid]["transcripts"]
    while i > 0:
      tr_l = local_transcripts[i-1]
      tr_l["full_name"] = transcriptionSessions[tsid][sid]["full_name"]

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
    
    transcriptionSessions[tsid]["transcripts"] = sorted(transcriptionSessions[tsid]["transcripts"], key=lambda x: x["timestamp"])

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
    close_room(tr.tsid)
