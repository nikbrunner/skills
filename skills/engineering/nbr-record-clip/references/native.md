# Native lane

`ffmpeg` captures the screen through AVFoundation at 60 fps and crops it to the app window. The capture runs in real time, so
a busy machine can stutter it: close heavy apps first. The terminal running the agent needs the Screen Recording permission
in System Settings.

## Find the screen and the window

```sh
ffmpeg -hide_banner -f avfoundation -list_devices true -i "" 2>&1 | grep "Capture screen"
osascript -e 'tell application "System Events" to get {position, size} of front window of process "<App>"'
```

The window position and size come back in points; the capture is in pixels. On a Retina screen, double all four values for
the crop and keep `scale=iw/2:-1` below to bring the clip back to point size. On a non-Retina screen, use the values as they
are and drop the scale.

## Capture

Put the window in its start state. Start the capture in the background from a fresh scratchpad directory, then ask the
person to drive the app, or drive it with a script. It stops after `-t` seconds:

```sh
cd <scratchpad-dir>
mkdir frames
ffmpeg -loglevel error -f avfoundation -framerate 60 -pixel_format bgr0 -capture_cursor 1 -i "<screen>:none" -t <seconds> \
  -vf "crop=<w>:<h>:<x>:<y>,scale=iw/2:-1" frames/f%05d.png
```

Delete lead-in frames from `frames/`, then encode as in [`SKILL.md`](../SKILL.md#encode) with `<fps>` 60. Check frames through
each transition. A stuttered capture jumps between neighbouring frames; record it again.

## Capture with Cap

`cap` records one window by its ID through ScreenCaptureKit, so the window may move and no crop or Retina math is needed.
`cap doctor` confirms the permission.

```sh
cd <scratchpad-dir>
cap record windows                       # id, owner, and bounds per window
cap record start --window <id> --fps 60 --duration <seconds> --path clip.cap
cap export clip.cap clip.mp4 --fps 60
mkdir frames && ffmpeg -loglevel error -i clip.mp4 frames/f%05d.png
```

Encode the frames as above. The export is already lossy, so the WebP encode may as well be too (`-quality 80`).

## Switch the scheme

An app that follows the system appearance switches with it. Note the current setting, set the scheme for each recording,
and set the noted value back at the end:

```sh
osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode'
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
```

An app with its own theme setting switches there.
