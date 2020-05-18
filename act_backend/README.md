# Running the ACT Backend

In production:
```bash
$ /home/fahimali/act/env/bin/gunicorn --worker-class eventlet -w 2 -b 127.0.0.1:3001 act_backend.app:app
```

Dev
```bash
$ act_backend dev
```