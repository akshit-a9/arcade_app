# GearUp Games Arcade App

## Overview
GearUp Games is an educational arcade app designed to promote road safety awareness through engaging and interactive games. The app includes five distinct games that challenge players’ skills while educating them on important road and traffic safety concepts. This app was developed using Flutter and Firebase as part of a six-week internship project.

## Features
### Games Included:
1. **Memory Master**
   - A memory matching game focused on road and traffic safety signs.
   - Enhances cognitive skills while educating players.
   - Interactive interface with multiple difficulty levels.

2. **Spin&Win**
   - A spin wheel game offering rewards like points and coupons.
   - Rewards are randomized, with data fetched from Firebase.
   - Additional attempts can be purchased using points.

3. **GoldenSlots**
   - A slot machine game with a road safety awareness theme.
   - Players win points and a jackpot when all slots show the number 7.
   - Adaptive difficulty and reward system.

4. **DriveQuest**
   - A driving game that uses the Google Maps API to generate 2D maps.
   - Players earn points by driving through known locations.
   - The game ends when the destination is reached.

5. **AMO Radio**
   - A radio feature that plays road safety awareness stories in Odia.
   - Educates players on safe driving practices through engaging storytelling.

### User Management
- **Google Sign-In**: Users can sign in using Google to sync their points and coins. Data is linked to their Google ID.
- **Guest Access**: Users who don't sign in start with 1000 coins and 0 points.
- **Coins and Points System**: Each game entry costs 50 coins. Additional attempts in GoldenSlots and Spin&Win cost 30 points each.
- **In-App Purchases**: Users can exchange points for coins and purchase coins with real money.

### Development Tools
- **Frontend**: Flutter
- **Backend**: Firebase
- **Maps Integration**: Google Maps API


### Prerequisites
- Flutter SDK
- Firebase account
- Google Maps API key

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/gearup-games.git
    cd gearup-games
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

3. Set up Firebase:
    - Create a Firebase project and add your Android/iOS app.
    - Download the `google-services.json` or `GoogleService-Info.plist` file and place it in the appropriate directory.

4. Enable Google Sign-In and configure Firestore in your Firebase project.

5. Obtain a Google Maps API key and add it to your `AndroidManifest.xml` or `Info.plist` file.

### Running the App
To run the app on an emulator or physical device, use:
```bash
flutter run
```
