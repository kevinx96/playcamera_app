# playcamera_app
Written in dart, running on Andriod studio
Yes you see where this is going, I wrote it in dart so it could be somehow compiled into iso and run on ios

# Android Developer Setup Guide (Local Server Environment)
# 1. Introduction
This guide is for Android developers working on the Playground Monitoring App.
To test the app's video streaming and image loading features, you must simulate the production environment. This involves running a local HTTP server on your machine to host HLS video files and analysis images. You will then use ngrok to expose this local server to the public internet, allowing the cloud API (and thus the app) to access it.
This guide covers:
Running a local HTTP server for HLS/image files.
Using ngrok to get a public URL for your local server.
Installing Android Studio to build and run the app.
Note: This guide assumes the AI analysis script (live_analysis_ngrok.py) [cite: live_analysis_mmpose.py] is being run by you or someone else, as it is responsible for generating the HLS files and images.
# 2. Part 1: Run the Local HLS & Image Server
The AI script saves its files to a local directory (e.g., D:\DetectedImages). You must "serve" this directory over HTTP so that other devices can access its contents.
Open a Command Prompt (cmd) or PowerShell.
Navigate to the Shared Folder. This folder must be the exact same folder specified by the SHARED_FOLDER_PATH variable in the AI script [cite: live_analysis_mmpose.py].
# Example using the default path
D:
cd D:\DetectedImages


Start the Python HTTP Server. This command serves the current directory's contents on port 8000.
python -m http.server 8000


Verification (Local): Open your browser and go to http://localhost:8000. You should see a file list of the D:\DetectedImages directory.
==> IMPORTANT: Keep this terminal window open. Closing it will shut down your HLS/image server.
# 3. Part 2: Expose the Server with ngrok
Your local server (localhost:8000) is only visible on your computer. ngrok creates a secure tunnel to the public internet.
Install ngrok:
Download ngrok from https://ngrok.com/download.
Unzip it to a stable location (e.g., C:\ngrok).
(Recommended) Add C:\ngrok to your system's Path environment variable.
Authenticate your account (get your token from the ngrok dashboard):
ngrok config add-authtoken <YOUR_AUTH_TOKEN>


Open a second, new Command Prompt.
Start ngrok to forward to your local HTTP server on port 8000.
ngrok http 8000


Get Your Public URL: ngrok will display a "Forwarding" URL, which looks like this:
Forwarding https://<random-string>.ngrok-free.dev
Copy this https:// URL. This is your public IMAGE_BASE_URL.
Update the Render API:
You MUST give this https://... URL to the backend team, or set it yourself.
Log in to Render.com.
Go to your API service (playground-api).
Go to "Environment".
Update the IMAGE_BASE_URL environment variable to this new ngrok URL.
This will trigger a re-deploy of your API. This step is critical so the API knows where to find your HLS stream [cite: api_v3.py].
==> IMPORTANT: Keep this second terminal window open. If you restart ngrok, you will get a new URL and you must update the Render environment variable again.
# 4. Part 3: Install Android Studio
This is the official IDE for building the Android app.
Download: Go to the official Android Studio download page and download the installer for Windows.
Install:
Run the installer (.exe).
Follow the setup wizard. The default components are fine. Ensure "Android Virtual Device" (AVD) is checked if you want to use an emulator.
The first time you run Android Studio, it will download the latest Android SDK and build-tools. This may take several minutes.
Get the Project:
Open Android Studio.
From the welcome screen, select "Get from VCS".
Paste the GitHub repository URL for your Android app project and click "Clone".
Sync Gradle:
Once the project is open, Android Studio will automatically try to "Sync" the project using Gradle.
This will download all the app's dependencies (libraries). This can also take several minutes. Wait for it to complete successfully.
# Run the App (Emulator):
In the top menu, go to Tools > AVD Manager (Android Virtual Device Manager).
Click + Create Virtual Device....
Select a device (e.g., "Pixel 6") and click Next.
Select a system image (e.g., API Level 33 or 34). You may need to click "Download" next to the name first.
Click Next and Finish.
Close the AVD Manager.
Your new emulator should appear in the device dropdown menu at the top of Android Studio.
Click the green "Run 'app'" button (▶).
# Run the App (Physical Device):
On your Android phone, go to Settings > About Phone and tap on Build Number seven (7) times to unlock "Developer options".
Go to Settings > System > Developer options and enable USB debugging.
Connect your phone to your PC via USB.
Accept the "Allow USB debugging?" prompt on your phone.
Your phone should now appear in the device dropdown menu.
Click the green "Run 'app'" button (▶).
# Run it manually
If you have trouble on both types, run the app manually by:
flutter run

also if you get troubled by virtual device builds, do this
flutter clean
flutter pub cache repair
flutter pub get
flutter run -v
