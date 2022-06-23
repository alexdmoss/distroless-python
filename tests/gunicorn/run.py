import sys
from gunicorn.app.wsgiapp import run

if __name__ == '__main__':
    sys.exit(run())
