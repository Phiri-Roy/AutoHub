import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../firebase_options.dart';

class FirebaseConfigService {
  static FirebaseApp? _app;
  static FirebaseMessaging? _messaging;
  static FirebaseAnalytics? _analytics;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseAuth? _auth;
  static FirebaseDatabase? _database;

  static bool _isInitialized = false;

  /// Initialize Firebase services
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        print('Firebase already initialized');
        return true;
      }

      // Initialize Firebase Core
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase Core initialized: ${_app?.name}');

      // Initialize Firebase services
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _auth = FirebaseAuth.instance;
      _database = FirebaseDatabase.instance;

      // Configure Firestore settings
      _firestore?.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Configure Analytics
      await _analytics?.setAnalyticsCollectionEnabled(true);

      _isInitialized = true;
      print('All Firebase services initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing Firebase: $e');
      return false;
    }
  }

  /// Get Firebase App instance
  static FirebaseApp? get app => _app;

  /// Get Firebase Messaging instance
  static FirebaseMessaging? get messaging => _messaging;

  /// Get Firebase Analytics instance
  static FirebaseAnalytics? get analytics => _analytics;

  /// Get Firestore instance
  static FirebaseFirestore? get firestore => _firestore;

  /// Get Firebase Storage instance
  static FirebaseStorage? get storage => _storage;

  /// Get Firebase Auth instance
  static FirebaseAuth? get auth => _auth;

  /// Get Firebase Database instance
  static FirebaseDatabase? get database => _database;

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  /// Get Firebase project ID
  static String? get projectId => _app?.options.projectId;

  /// Get Firebase app ID
  static String? get appId => _app?.options.appId;

  /// Test Firebase connectivity
  static Future<bool> testConnectivity() async {
    try {
      if (!_isInitialized) {
        print('Firebase not initialized');
        return false;
      }

      // Test Firestore connectivity
      await _firestore?.collection('test').limit(1).get();
      print('Firestore connectivity test passed');

      // Test Auth connectivity
      final currentUser = _auth?.currentUser;
      print(
        'Auth connectivity test passed. Current user: ${currentUser?.uid ?? 'None'}',
      );

      // Test Storage connectivity
      _storage?.ref().child('test');
      print('Storage connectivity test passed');

      return true;
    } catch (e) {
      print('Firebase connectivity test failed: $e');
      return false;
    }
  }

  /// Get Firebase configuration info
  static Map<String, dynamic> getConfigInfo() {
    if (!_isInitialized) {
      return {'error': 'Firebase not initialized'};
    }

    return {
      'projectId': projectId,
      'appId': appId,
      'isInitialized': _isInitialized,
      'authUser': _auth?.currentUser?.uid,
      'firestoreEnabled': _firestore != null,
      'storageEnabled': _storage != null,
      'messagingEnabled': _messaging != null,
      'analyticsEnabled': _analytics != null,
      'databaseEnabled': _database != null,
    };
  }

  /// Reset Firebase (for testing)
  static Future<void> reset() async {
    try {
      await _app?.delete();
      _app = null;
      _messaging = null;
      _analytics = null;
      _firestore = null;
      _storage = null;
      _auth = null;
      _database = null;
      _isInitialized = false;
      print('Firebase reset successfully');
    } catch (e) {
      print('Error resetting Firebase: $e');
    }
  }
}
