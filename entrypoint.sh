#!/bin/bash
# entrypoint.sh

# Kill any leftover VNC servers
tightvncserver -kill :1 &>/dev/null || true

# Remove stale lock files
rm -f /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1

# Start a fresh VNC server
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
