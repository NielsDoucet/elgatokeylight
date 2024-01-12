# Elgato Key Light Air Automation on macOS

Automate Elgato Key Light Air to switch on automatically when you start your camera switches it off when the camera
turns off.

I've found it a hassle to remember to switch my lights on and off as I join various video calls throughout the day.
This bash script monitors the macOS stream log and runs a curl command to toggle the lights.

## Monitoring camera stream on macOS 12.x+ (Monterey, Ventura)

`log stream --predicate 'subsystem == "com.apple.UVCExtension" and composedMessage contains "Post PowerLog"'`

Monitors the stream log on macOS and filters out any video capture on macOS 12.x+ (Monterey, Ventura)
For older versions of macOS, check out the good work
at: https://gist.github.com/jptoto/3b2197dd652ef13bd7f3cab0f2152b19.

## Turning the Elgato Key Light Air On and Off

```shell
curl --location --request PUT 'https://<light IP address>:9123/elgato/lights' \
  --header 'Content-Type: application/json' \
  --data-raw '{"lights":[{"brightness":40,"temperature":162,"on":1}],"numberOfLights":1}'
```

credit: https://vninja.net/2020/12/04/automating-elgato-key-lights-from-touch-bar/

You need to provide a file containing the local IP addresses of the lights based on your local setup. One line per ip.
The rest of the key/value pairs to configure the lights are self-explanatory.

## Running the script and testing if everything works

You can run the script using Terminal, download the .sh file, edit it and run:

```shell
sh autolights.sh <path to ip list file> &
```

This will start to monitor your stream log. Open any app that uses your web camera and see if your light(s) come on.
If they do not, check that you have entered the correct IP address(es) for your light(s).
The easiest way to identify the IP address is to use the `Elgato Control Center utility` > `Key light settings` and note
the IP address for each light.

## Executing the shell script automatically

If you prefer to run the bash script everytime you start up your Mac to avoid starting it manually, adapt the
`com.elgato.autolights.daemon.plist` file to point to the `autolights.sh` and ip list files and copy it to
the `~/Library/LaunchAgents/` folder.

May you see the light! 🔦 😆
