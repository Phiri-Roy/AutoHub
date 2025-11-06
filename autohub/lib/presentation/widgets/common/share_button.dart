import 'package:flutter/material.dart';
import '../../../data/services/sharing_service.dart';

class ShareButton extends StatelessWidget {
  final String? content;
  final String? imageUrl;
  final String? authorName;
  final String? eventName;
  final String? eventDate;
  final String? eventLocation;
  final String? eventDescription;
  final String? carMake;
  final String? carModel;
  final int? carYear;
  final String? carImageUrl;
  final String? modifications;
  final String? ownerName;
  final int? leaderboardPosition;
  final int? totalWins;
  final ShareType shareType;
  final IconData? icon;
  final String? label;
  final Color? color;

  const ShareButton({
    super.key,
    this.content,
    this.imageUrl,
    this.authorName,
    this.eventName,
    this.eventDate,
    this.eventLocation,
    this.eventDescription,
    this.carMake,
    this.carModel,
    this.carYear,
    this.carImageUrl,
    this.modifications,
    this.ownerName,
    this.leaderboardPosition,
    this.totalWins,
    required this.shareType,
    this.icon,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon ?? Icons.share),
      color: color ?? Theme.of(context).colorScheme.primary,
      onPressed: () => _handleShare(context),
      tooltip: label ?? 'Share',
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    try {
      switch (shareType) {
        case ShareType.post:
          await SharingService.sharePost(
            content: content ?? '',
            imageUrl: imageUrl,
            authorName: authorName,
          );
          break;
        case ShareType.event:
          await SharingService.shareEvent(
            eventName: eventName ?? '',
            eventDate: eventDate ?? '',
            eventLocation: eventLocation ?? '',
            eventDescription: eventDescription,
            imageUrl: imageUrl,
          );
          break;
        case ShareType.car:
          await SharingService.shareCar(
            carMake: carMake ?? '',
            carModel: carModel ?? '',
            carYear: carYear ?? DateTime.now().year,
            carImageUrl: carImageUrl,
            modifications: modifications,
            ownerName: ownerName,
          );
          break;
        case ShareType.leaderboard:
          await SharingService.shareLeaderboard(
            carMake: carMake ?? '',
            carModel: carModel ?? '',
            carYear: carYear ?? DateTime.now().year,
            position: leaderboardPosition ?? 1,
            totalWins: totalWins ?? 0,
            carImageUrl: carImageUrl,
          );
          break;
        case ShareType.app:
          await SharingService.shareApp();
          break;
        case ShareType.custom:
          await SharingService.shareWithCustomText(content ?? '');
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

enum ShareType { post, event, car, leaderboard, app, custom }

class ShareButtonWithText extends StatelessWidget {
  final String? content;
  final String? imageUrl;
  final String? authorName;
  final String? eventName;
  final String? eventDate;
  final String? eventLocation;
  final String? eventDescription;
  final String? carMake;
  final String? carModel;
  final int? carYear;
  final String? carImageUrl;
  final String? modifications;
  final String? ownerName;
  final int? leaderboardPosition;
  final int? totalWins;
  final ShareType shareType;
  final String label;
  final IconData? icon;

  const ShareButtonWithText({
    super.key,
    this.content,
    this.imageUrl,
    this.authorName,
    this.eventName,
    this.eventDate,
    this.eventLocation,
    this.eventDescription,
    this.carMake,
    this.carModel,
    this.carYear,
    this.carImageUrl,
    this.modifications,
    this.ownerName,
    this.leaderboardPosition,
    this.totalWins,
    required this.shareType,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleShare(context),
      icon: Icon(icon ?? Icons.share),
      label: Text(label),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    try {
      switch (shareType) {
        case ShareType.post:
          await SharingService.sharePost(
            content: content ?? '',
            imageUrl: imageUrl,
            authorName: authorName,
          );
          break;
        case ShareType.event:
          await SharingService.shareEvent(
            eventName: eventName ?? '',
            eventDate: eventDate ?? '',
            eventLocation: eventLocation ?? '',
            eventDescription: eventDescription,
            imageUrl: imageUrl,
          );
          break;
        case ShareType.car:
          await SharingService.shareCar(
            carMake: carMake ?? '',
            carModel: carModel ?? '',
            carYear: carYear ?? DateTime.now().year,
            carImageUrl: carImageUrl,
            modifications: modifications,
            ownerName: ownerName,
          );
          break;
        case ShareType.leaderboard:
          await SharingService.shareLeaderboard(
            carMake: carMake ?? '',
            carModel: carModel ?? '',
            carYear: carYear ?? DateTime.now().year,
            position: leaderboardPosition ?? 1,
            totalWins: totalWins ?? 0,
            carImageUrl: carImageUrl,
          );
          break;
        case ShareType.app:
          await SharingService.shareApp();
          break;
        case ShareType.custom:
          await SharingService.shareWithCustomText(content ?? '');
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
