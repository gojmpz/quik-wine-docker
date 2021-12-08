#!/bin/bash
DISPLAY_RESOLUTION='1600x1000x24'
ENABLE_VNC='1'
VNC_PASSWORD='qweasd'
QUIK_LOGIN='quik_login'
QUIK_PASSWORD='quik_password'
WAIT_BEFORE_LOGIN='60s'

docker run \
  -v "$PWD"/quik:/quik \
  -v "$PWD"/quik_config:/quik_config \
  -v "$PWD"/quik_key:/quik/key \
  -v "$PWD"/lua_scripts:/quik/lua \
  -e DISPLAY_RESOLUTION=$DISPLAY_RESOLUTION \
  -e ENABLE_VNC=$ENABLE_VNC \
  -e VNC_PASSWORD=$VNC_PASSWORD \
  -e QUIK_LOGIN=$QUIK_LOGIN \
  -e QUIK_PASSWORD=$QUIK_PASSWORD \
  -e WAIT_BEFORE_LOGIN=$WAIT_BEFORE_LOGIN \
  -p 5900:5900 \
  -d \
  --name quik \
  --rm \
quik-wine-docker:latest
