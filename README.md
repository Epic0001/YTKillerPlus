# YTKillerPlus

A Cydia Substrate tweak for YouTube on iOS — ad blocking, background play, SponsorBlock, speed control, UI cleanup, and downloads.

![Build](https://github.com/Epic0001/YTKillerPlus/actions/workflows/build.yml/badge.svg)

---

## Features

| Feature | Description |
|---|---|
| **Ad Blocking** | Removes banner, overlay, and midroll ads; auto-skips skippable ads |
| **Background Play** | Keeps audio playing when the app is backgrounded |
| **Picture in Picture** | Enables PiP for all videos |
| **SponsorBlock** | Automatically skips sponsored segments via [sponsor.ajay.app](https://sponsor.ajay.app) |
| **Speed Control** | On-screen pill to adjust playback speed (0.25× – 3×), saved between sessions |
| **Downloads** | Download button in the player overlay (requires a stream resolver — see below) |
| **UI Cleanup** | Hide Shorts tab/feed, comments, end cards, watermarks, cast button, notification bell, and more |

---

## Requirements

- Jailbroken iOS 14.0+ (arm64)
- [Cydia Substrate](https://cydia.saurik.com/package/mobilesubstrate/) or [Substitute](https://github.com/coolstar/substitute)
- [PreferenceLoader](https://cydia.saurik.com/package/preferenceloader/)
- YouTube app (tested on 19.x)

---

## Building

### Prerequisites

Install [Theos](https://theos.dev/docs/installation):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
```

### Build

```bash
make package
```

### Install to device

```bash
export THEOS_DEVICE_IP=<your-device-ip>
make package install
```

---

## Downloads note

The download module injects a button and handles queue/file management, but resolving a valid stream URL requires a separate component since YouTube signs stream URLs server-side. Options:

- Run a local [yt-dlp](https://github.com/yt-dlp/yt-dlp) HTTP server and point `YTKDownloadManager` at it
- Use a self-hosted [cobalt](https://github.com/imputnet/cobalt) instance

---

## Settings

All features are toggleable under **Settings → YTKillerPlus**.

---

## License

MIT
