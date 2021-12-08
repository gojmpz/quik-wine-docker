#!/usr/bin/env bash
# good example
# https://github.com/scottyhardy/docker-wine
export LANG=en_US.UTF-8

DISPLAY_RESOLUTION=${DISPLAY_RESOLUTION:-1600x1000x24}
ENABLE_VNC=${ENABLE_VNC:-1}
VNC_PASSWORD=${VNC_PASSWORD:-qweasd}
QUIK_LOGIN=${QUIK_LOGIN:-quik_login}
QUIK_PASSWORD=${QUIK_PASSWORD:-quik_password}
WAIT_BEFORE_LOGIN=${WAIT_BEFORE_LOGIN:-60s}
set_display()
{
  # taken from https://github.com/EA31337/EA-Tester/blob/master/scripts/.funcs.cmds.inc.sh
  export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree,mshtml=,winebrowser.exe=}" # Disable gecko and default browser in wine.
  export WINEDEBUG="${WINEDEBUG:-warn-all,fixme-all,err-alsa,-ole,-toolbar}"      # For debugging, try: WINEDEBUG=trace+all
  export DISPLAY=${DISPLAY:-:0}                                                   # Select screen 0 by default.
  xdpyinfo &> /dev/null && return
  ! pgrep -a Xvfb && Xvfb "$DISPLAY" -screen 0 "$DISPLAY_RESOLUTION" || true &
  sleep 1
  if command -v fluxbox &> /dev/null; then
    ! pgrep -a fluxbox && fluxbox 2> /dev/null || true &
  fi
  echo "INFO: IP: $(hostname -I) ($(hostname))"
}

add_vnc()
{
  if [[ "$ENABLE_VNC" == 1 ]]; then
    if [[ -z "${VNC_PASSWORD}" ]]; then
      echo "Error: environmental variable VNC_PASSWORD is not defined, vnc access is not allowed without password."
      exit 1
    else
      mkdir /root/.vnc
      AUTH_FILE="/root/.vnc/passwd"
      x11vnc -storepasswd "$VNC_PASSWORD" $AUTH_FILE
      if command -v x11vnc &> /dev/null; then
        ! pgrep -a x11vnc && x11vnc -bg -forever -nopw -quiet -display WAIT$DISPLAY -rfbauth "$AUTH_FILE" || true &
      fi 1>&2
    fi
  fi
}
cd /quik || exit 1
#starting xserver
set_display
# enabling VNC
add_vnc
# quik can work without vcrun6 trick, so the script will continue if install failed
/winetricks --country=RU -q vcrun6 || true

# adding layouts to be able to enter russian letters inside quik
setxkbmap -layout us,ru -option grp:caps_toggle
setxkbmap -query

cp -ap /quik_config/. /quik/

login()
{
  echo "waiting $WAIT_BEFORE_LOGIN before logging in..."
  sleep "$WAIT_BEFORE_LOGIN"
  echo "the wait is over, trying to login to quik"
  # imitating login
  xte "str $QUIK_LOGIN"
  xte "key Tab"
  xte "str $QUIK_PASSWORD"
  xte "key Return"
}
login &

LC_ALL=ru_RU.UTF-8 wine info.exe
