#!/bin/sh
vLang=$1
if [ "$vlang"="go" ]; then
cd ~ && curl -O https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz
tar -C /usr/local -xzf ~/go1.13.5.linux-amd64.tar.gz
export GOPATH=/code
echo -e export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin" > $HOME/.profile
source $HOME/.profile
cd /code/$vLang/ && go build  -o runme
./runme
#tail -f /dev/null
fi
