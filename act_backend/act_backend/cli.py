import sys

def cli():
  if len(sys.argv) == 1:
    print("Try 'act_backend dev'")
    return
  
  if sys.argv[1] == 'dev':
    from act_backend.app import start_dev_server
    start_dev_server()
  else:
    print('Invalid Command')
  return