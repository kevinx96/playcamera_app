# playcamera_app

A Flutter/Dart Android app for playground monitoring. This README contains a concise developer setup guide for running a local HLS/image server and exposing it with ngrok so the cloud API can access test streams and images.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [1. Run the Local HLS & Image Server](#1-run-the-local-hls--image-server)
- [2. Expose the Server with ngrok](#2-expose-the-server-with-ngrok)
- [3. Update the Render API](#3-update-the-render-api)
- [4. Install Android Studio & Run the App](#4-install-android-studio--run-the-app)
- [Quick Flutter Commands](#quick-flutter-commands)

---

## Overview

This guide helps Android developers simulate the production environment locally so the app can load HLS video files and analysis images produced by the AI analysis script (e.g. `live_analysis_ngrok.py`). The script saves files to a shared folder which must be served over HTTP and exposed to the internet using ngrok.

## Prerequisites

- Python (to run a simple HTTP server)
- ngrok account and the ngrok binary
- Android Studio (or Flutter toolchain if using `flutter run`)
- The AI analysis script running and writing files to the shared folder (e.g. `D:\DetectedImages`).


## 1. Run the Local HLS & Image Server

Serve the folder used by the AI script (the folder set in `SHARED_FOLDER_PATH`) over HTTP so other devices (and the cloud API) can access it.

Open PowerShell and run:

```powershell
# Switch to the drive (if needed) and change directory
D:
cd D:\DetectedImages

# Start the Python HTTP server on port 8000
python -m http.server 8000
```

Verify locally by opening http://localhost:8000 in your browser — you should see the directory listing. IMPORTANT: keep this terminal open; closing it stops the server.


## 2. Expose the Server with ngrok

ngrok creates a secure tunnel from the public internet to your local server so the cloud API can fetch images/HLS.

Install and authenticate ngrok:

```bash
# Download ngrok from https://ngrok.com/download and unzip to e.g. C:\ngrok
# (Optional) add to PATH
# Authenticate with your token (one-time)
ngrok config add-authtoken <YOUR_AUTH_TOKEN>
```

Start a tunnel pointing to your local server (run this in a separate terminal window):

```bash
ngrok http 8000
```

ngrok will print one or more "Forwarding" URLs, e.g.:

```
Forwarding https://<random-string>.ngrok-free.dev -> http://localhost:8000
```

Copy the https:// URL — this is your public IMAGE_BASE_URL.

IMPORTANT: Keep this ngrok terminal open. If you restart ngrok you will get a new URL and must update the backend accordingly.


## 3. Update the Render API

The backend needs to know the public `IMAGE_BASE_URL` so it can reference your local HLS/images.

1. Log in to Render.com.
2. Navigate to your API service (e.g., `playground-api`).
3. Open the "Environment" or environment variables section.
4. Set `IMAGE_BASE_URL` to the ngrok https URL you copied.

This change will trigger a re-deploy of the API so it can use your local server. Share the URL with the backend team if you are not updating Render yourself.


## 4. Install Android Studio & Run the App

Install Android Studio (Windows):

- Download the installer from the official Android Studio page and run it.
- During setup, ensure "Android Virtual Device" (AVD) is selected if you plan to use an emulator.

Open the project:

- Launch Android Studio → Get from VCS → paste the repository URL and clone.
- Allow Gradle to sync and download dependencies.

Run on an emulator:

1. Tools > AVD Manager > Create a Virtual Device (e.g., Pixel 6).
2. Select a system image (API level 33/34) and finish.
3. Select the emulator and click Run ▶ in Android Studio.

Run on a physical device:

1. Enable Developer options on the phone (tap Build Number 7 times).
2. Enable USB debugging in Developer options.
3. Connect the phone by USB and accept the debugging prompt.
4. Select the device in Android Studio and click Run ▶.


## Quick Flutter Commands

If you prefer running from the terminal or encounter build issues, these Flutter commands can help:

```bash
# Run the app from the project root
flutter run

# Troubleshooting: clean and restore packages
flutter clean
flutter pub cache repair
flutter pub get
# Run with verbose logging
flutter run -v
```


---

If you want additional sections (examples of expected HLS file layout, sample IMAGE_BASE_URL values, or a troubleshooting checklist), tell me which section to add and I will include it.
