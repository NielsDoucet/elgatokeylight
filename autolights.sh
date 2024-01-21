#!/bin/bash
# Define light ips
IFS=$'\n' read -d '' -r -a ips < $1
echo "connecting to lights on ips ${ips[@]}"

send_payload() {
  for ip in "${ips[@]}"; do
    curl -s -L -X PUT "http://$ip:9123/elgato/lights" -H 'Content-Type: application/json' -d "$1" -o /dev/null
  done
}

toggle_lights() {
  send_payload "{\"lights\":[{\"on\":$1}]}"
}

detect_camera_ventura() {
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
}

detect_camera_sonoma() {
  # Begin looking at the system log via the stream sub-command.
  # Using a --predicate and filtering by the correct and pull out the camera event
  log stream --predicate 'composedMessage contains "AppleH13CamIn::power_"' | while read -r line; do
    # If we catch a camera start event, turn the light on.
    if echo "$line" | grep -qE "power_on_hardware$"; then
      toggle_lights 1
    fi

    # If we catch a camera stop event, turn the light off.
    if echo "$line" | grep -qE "power_off_hardware$"; then
      toggle_lights 0
    fi
  done
}

# Run based on major version of MacOS
major=$(sw_vers -productversion | cut -d. -f1)
if [[ $major -ge 14 ]]; then detect_camera_sonoma
elif [[ $major -le 13 ]]; then detect_camera_ventura
fi