#!/bin/bash
# Define light ips
ips=$(cat "$1" | tr "\n" " ")

send_payload() {
  for ip in "${ips[@]}"; do
    curl -s -L -X PUT "http://$ip:9123/elgato/lights" -H 'Content-Type: application/json' -d "$1" -o /dev/null
  done
}

toggle_lights() {
  send_payload "{\"lights\":[{\"on\":$1}]}"
}

# Begin looking at the system log via the stream sub-command.
# Using a --predicate and filtering by the correct and pull out the camera event
log stream --predicate 'subsystem == "com.apple.UVCExtension" and composedMessage contains "Post PowerLog"' | while read -r line; do
  # If we catch a camera start event, turn the light on.
  if echo "$line" | grep -q "= On"; then
    toggle_lights 1
  fi

  # If we catch a camera stop event, turn the light off.
  if echo "$line" | grep -q "= Off"; then
    toggle_lights 0
  fi
done
