import 'package:share_plus/share_plus.dart';

class SharingService {
  static Future<void> sharePost({
    required String content,
    String? imageUrl,
    String? authorName,
  }) async {
    String shareText = '';

    if (authorName != null) {
      shareText += 'Check out this post by $authorName on AutoHub:\n\n';
    }

    shareText += content;

    if (imageUrl != null) {
      shareText += '\n\nView the full post with images on AutoHub!';
    }

    shareText += '\n\nDownload AutoHub to join the car community!';

    await Share.share(shareText);
  }

  static Future<void> shareEvent({
    required String eventName,
    required String eventDate,
    required String eventLocation,
    String? eventDescription,
    String? imageUrl,
  }) async {
    String shareText = 'Join me at this car event on AutoHub!\n\n';
    shareText += '🚗 $eventName\n';
    shareText += '📅 $eventDate\n';
    shareText += '📍 $eventLocation\n';

    if (eventDescription != null && eventDescription.isNotEmpty) {
      shareText += '\n$eventDescription\n';
    }

    shareText += '\nDownload AutoHub to RSVP and connect with car enthusiasts!';

    await Share.share(shareText);
  }

  static Future<void> shareCar({
    required String carMake,
    required String carModel,
    required int carYear,
    String? carImageUrl,
    String? modifications,
    String? ownerName,
  }) async {
    String shareText = '';

    if (ownerName != null) {
      shareText += 'Check out $ownerName\'s car on AutoHub:\n\n';
    }

    shareText += '🚗 $carYear $carMake $carModel\n';

    if (modifications != null && modifications.isNotEmpty) {
      shareText += '\nModifications:\n$modifications\n';
    }

    shareText +=
        '\nDownload AutoHub to showcase your car and connect with enthusiasts!';

    await Share.share(shareText);
  }

  static Future<void> shareLeaderboard({
    required String carMake,
    required String carModel,
    required int carYear,
    required int position,
    required int totalWins,
    String? carImageUrl,
  }) async {
    String shareText = '🏆 I\'m #$position on the AutoHub leaderboard!\n\n';
    shareText +=
        'My $carYear $carMake $carModel has $totalWins featured car wins!\n\n';
    shareText += 'Download AutoHub to compete and showcase your cars!';

    await Share.share(shareText);
  }

  static Future<void> shareApp() async {
    const String shareText =
        'Check out AutoHub - the ultimate car enthusiast community app! 🚗\n\n'
        '• Showcase your cars\n'
        '• Join car events\n'
        '• Vote for featured cars\n'
        '• Connect with enthusiasts\n'
        '• Compete on the leaderboard\n\n'
        'Download now and join the community!';

    await Share.share(shareText);
  }

  static Future<void> shareWithCustomText(String text) async {
    await Share.share(text);
  }
}
