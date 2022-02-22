[![unifi-cam-proxy Discord](https://img.shields.io/discord/937237037466124330?color=0559C9&label=Discord&logo=discord&logoColor=%23FFFFFF&style=for-the-badge)](https://discord.gg/Bxk9uGT6MW)

UniFi Camera Proxy
==================
## About

This enables using non-Ubiquiti cameras within the UniFi Protect ecosystem. This is
particularly useful to use existing RTSP-enabled cameras in the same UI and
mobile app as your other Unifi devices.

Things that work:
* Live streaming
* Full-time recording
* Motion detection with certain cameras
* Smart Detections using [Frigate](https://github.com/blakeblackshear/frigate)

## Documentation

View the documentation at https://unifi-cam-proxy.com

## Debugging

Using [Visual Studio Code](https://code.visualstudio.com/Download) you can open this project within the provided devcontainer, which will configure the python development environment for you and allow you to step through and debug the code.  You can create a custom .vscode\launch.json file to pass in the parameters that you need eg:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "unifi-cam-proxy",
            "type": "python",
            "request": "launch",
            "module": "main",
            "cwd": "${workspaceFolder}/unifi",
            "args": [
                "--host={your-ip}",
                "--token={your-token}",
                "--mac={your-mac}",
                "--cert=../client.pem",
                "rtsp",
                "-s={your-rtsp}",
                "--ffmpeg-args={your-ffmpeg-args}"
            ],
            "console": "integratedTerminal"
        }
    ]
}
```

## Donations

If you would like to make a donation to support development, please use [Github Sponsors](https://github.com/sponsors/keshavdv).
