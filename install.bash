#!/bin/bash

set -e

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$MYDIR"

source "$MYDIR/config"

#--- Constants ---
if [[ "$PORT" = "77777" ]]; then
  echo "Invalid port: $PORT. Please use the port assigned to the Proxy Port application."
  exit 1
fi

#--- Do Substitutions ---
mkdir -p "$PREFIX/src"
cp -r "$MYDIR/templates" "$PREFIX/src"
cd "$PREFIX/src/templates"
source substitutions.bash

#--- Initial Config ---
mkdir -p "$PREFIX"/{bin,conf,etc,lib,var/run,tmp}
cp "$PREFIX/src/templates/httpd.conf.template" "$PREFIX/conf/httpd.conf"

mkdir -p "$LOGDIR"
ln -s "$LOGDIR" "$PREFIX/log"

if ! [[ -f "$APPDIR1/wsgi.py" ]]; then
  cp "$MYDIR/templates/wsgi.py" "$APPDIR1/"
fi

#--- Create venv (python version must match mod_wsgi) ---
cd "$PREFIX"
python3.6 -m venv env
source env/bin/activate
pip install --upgrade pip
pip install wheel
deactivate

#--- Create start/stop/restart scripts ---
cd "$PREFIX/bin"

ln -s "/usr/sbin/httpd" "$PREFIX/bin/httpd"

cat << "EOF" > start
#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$MYDIR/httpd -d "$(dirname $MYDIR)"
EOF

cat << "EOF" > stop
#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
kill $(cat "$MYDIR/../var/run/httpd.pid") &> /dev/null
EOF

cat << "EOF" > restart
#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$MYDIR/stop"
sleep 3
"$MYDIR/start"
EOF

chmod 755 start stop restart

#--- Remove temporary files ---
rm -r "$PREFIX/src"

#--- Create cron entry ---
line="\n# $STACKNAME stack\n*/10 * * * * $PREFIX/bin/start &>/dev/null"
(crontab -l 2>/dev/null || true; echo -e "$line" ) | crontab -

#--- Start the application ---
$PREFIX/bin/start
