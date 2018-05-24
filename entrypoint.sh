#!/bin/sh
set -e


function replace_vars() {
eval "cat <<EOF
`cat $2`
EOF" >> $1
}



if [ ! -d '/repo' ];then
  echo create /repo
  svnadmin create --fs-type fsfs /repo
fi

# Apache gets grumpy about PID files pre-existing
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
