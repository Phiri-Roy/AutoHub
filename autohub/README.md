# AutoHub - Car Enthusiast Community App

AutoHub is a Flutter-based mobile application that serves as a social platform for car enthusiasts. Users can create and attend car-related events, showcase their vehicles, interact with a community feed, and participate in a voting system that highlights top cars on a leaderboard.

## Features

### 🔐 User Authentication
- Secure user registration and login with email/password
- User profile management with photo uploads
- Social login integration ready

### 🚗 My Garage
- Add and manage car details (Make, Model, Year, Photos, Modifications)
- Upload multiple car images
- Track modifications and descriptions

### 📅 Event Management
- Create car events with location, date, and time
- Browse upcoming events
- Join/leave events
- Event detail screens with attendee lists

### 🏆 Featured Car Showcase & Voting
- Submit cars from "My Garage" to events
- Vote for favorite submitted cars
- One vote per user per event
- Featured car highlighting based on votes

### 📱 Community Feed
- Social feed with posts and images
- Like and comment functionality
- Create posts with text and multiple images

### 🏅 Leaderboard
- Global leaderboard showcasing cars with most "Featured Car" wins
- Ranked list of top users and their cars
- Competitive element for the community

## Technology Stack

- **Frontend**: Flutter (Cross-platform mobile development)
- **State Management**: Riverpod
- **Backend**: Firebase
  - Authentication: Firebase Auth
  - Database: Cloud Firestore
  - Storage: Firebase Cloud Storage
- **UI**: Material Design 3 with custom theming
- **Image Handling**: Image Picker, Cached Network Image

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── constants.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── event_model.dart
│   │   ├── post_model.dart
│   │   └── event_submission_model.dart
│   └── services/
│       ├── auth_service.dart
│       └── firestore_service.dart
├── presentation/
│   ├── main_navigation.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── auth_wrapper.dart
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── feed/
│   │   │   ├── feed_screen.dart
│   │   │   └── create_post_screen.dart
│   │   ├── events/
│   │   │   ├── events_screen.dart
│   │   │   ├── create_event_screen.dart
│   │   │   ├── event_detail_screen.dart
│   │   │   └── submit_car_screen.dart
│   │   ├── leaderboard/
│   │   │   └── leaderboard_screen.dart
│   │   └── profile/
│   │       ├── profile_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       ├── my_garage_screen.dart
│   │       └── add_car_screen.dart
│   └── widgets/
│       ├── common/
│       │   └── custom_button.dart
│       ├── post_card.dart
│       └── event_card.dart
└── providers/
    └── app_providers.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### 1. Clone the Repository
```bash
git clone <repository-url>
cd autohub
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "AutoHub"
3. Enable Authentication, Firestore Database, and Storage

#### Configure Authentication
1. Go to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Optionally enable Google Sign-in

#### Configure Firestore
1. Go to Firestore Database
2. Create database in production mode
3. Set up security rules (see below)

#### Configure Storage
1. Go to Storage
2. Create storage bucket
3. Set up security rules (see below)

#### Update Firebase Configuration
1. Run `flutterfire configure` in the project root
2. Select your Firebase project
3. Choose platforms (Android, iOS, Web)
4. This will update `lib/firebase_options.dart`

### 4. Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events are readable by all authenticated users
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.createdBy || 
         request.auth.uid == request.resource.data.createdBy);
    }
    
    // Posts are readable by all authenticated users
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.postedBy || 
         request.auth.uid == request.resource.data.postedBy);
    }
    
    // Event submissions
    match /eventSubmissions/{submissionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == request.resource.data.userId);
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /car_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /post_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. Run the App
```bash
flutter run
```

## Development Roadmap

### Completed ✅
- [x] Project setup and Firebase integration
- [x] User authentication system
- [x] User profiles and My Garage feature
- [x] Event creation and management
- [x] Featured car showcase and voting system
- [x] Social feed with posts, likes, and comments
- [x] Global leaderboard for top cars
- [x] UI/UX polish and theming

### Future Enhancements 🚀
- [ ] Push notifications for events and comments
- [ ] Real-time chat for events
- [ ] Advanced search and filtering
- [ ] Car comparison features
- [ ] Social sharing integration
- [ ] Offline support
- [ ] Dark mode theme
- [ ] Advanced analytics and insights

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@autohub.com or join our Discord community.

---

**AutoHub** - Where Car Enthusiasts Connect! 🚗💨