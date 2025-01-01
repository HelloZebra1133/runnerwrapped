# RunnerWrapped App

RunnerWrapped is a mobile app created using Flutter Dart. It is an interactive experience designed to showcase your year's active journey in a fun and visual way. It takes your data and presents it through a series of slides, each highlighting different aspects of your year, such as distance traveled, time spent, steps taken, and more. Users can also capture and save the slides to share their progress, and celebrate their accomplishments.

## Features

- **Slide-Based Presentation**: View your fitness activities in an engaging slide format.
- **Music**: Background music accompanies your personalised slides.
- **Stats Overview**: View detailed statistics about your activities, such as total distance, time spent, and calories burned.
- **Slide Capture**: Take captures of any slide by clicking on the camera button. This will save them to your gallery in a folder named RunnerWrapped.
- **Progress Bar**: A visual progress bar to track your journey through the slides.

---

# Usage Instructions
1. **Launch the App**
   Once the app is running, you will be presented with a screen containing a button in the center.

2. **Select the Zip File**
   After the button is clicked you will be prompted to select the zip file containing your activities (Download this from your Strava account).

3. **Wait for Processing to Finish**
   There will be an indicator displaying the stage of the file processing. (Please note: As this entire process runs locally time may vary depending on device etc. but usually it only takes a matter of seconds)

4. **Slides will Display**
   After finishing with the analysis of your zip file's content, your personalised slides will be displayed.

2. **Navigation**
   Automatic Navigation: The app automatically transitions to the next slide every 6 seconds. The progress is shown through a linear progress bar at the top of the screen.
   Manual Navigation: You can swipe left or right to move between slides.
3. **View Your Stats**
   Each slide showcases a different statistic related to your activities (e.g., total distance, calories burned, etc.).
4. **Screenshot Capture**
   To capture a screenshot of any slide, press the Floating Camera Button located in the bottom-right corner of the screen.
   The app will prompt you to allow access to your photo gallery (on Android, iOS may have its own permissions).
   After capturing the screenshot, the app will save it to your device's gallery in a folder named RunnerWrapped.
5. **Share Your Highlights**
   At the end of the presentation, you’ll see a final slide inviting you to share your achievements with others. You can do so by going to your gallery where the slides you captured are located (a folder named RunnerWrapped).

---

# Downloading Your Strava Data
[Guide on Strava Website](https://support.strava.com/hc/en-us/articles/216918437-Exporting-your-Data-and-Bulk-Export#h_01GG58HC4F1BGQ9PQZZVANN6WF)
To use the RunnerWrapped app you will need your Strava data. This you can download as a ZIP file containing your activity data from Strava. Here's how you can do it:


1. Log into the account on Strava.com from which you wish to bulk export data.
2. Hover over your name in the upper right-hand corner of the Strava page.
3. Choose "Settings".
4. Find the "My Account" tab from the menu listed on the Left.
5. Select “Get Started” under “Download or Delete Your Account.”
6. Select “Request your archive” on the next page.
7. You will receive an email to the account linked with your Strava account. The email will contain a link to download your data.
8. Import the zip file into the RunnerWrapped app and watch the magic happen!


# How the App Works
## Data
The app expects a list of data (e.g. Strava zip file) that contains key information such as:

- Total distance traveled
- Total time spent
- Elevation gain
- Calories burned
- Total steps

The app uses this data to populate the stats locally on each slide dynamically.

## Background Audio
The app features background music that starts playing as soon as the app is launched and loops throughout the presentation.

## Timer
A timer runs in the background to automatically transition the slides every 6 seconds. If you manually swipe to a new slide, the timer is reset.

## Extra Details
Everything happens on your device so nothing is uploaded or sent anywhere without you manually sharing the pictures of the slides.
The Strava zip file may contain profile info that you are more than welcome to remove before opening the zip file in RunnerWrapped as the app does not require or even use such files. The following files are all that are currently required for the app to display the correct data (in a zip file):
- activities.csv
- activities
  - \[activity numbers].fit.gz

This was created for family and friends but feel free to take a look! I might improve this from time-to-time.

