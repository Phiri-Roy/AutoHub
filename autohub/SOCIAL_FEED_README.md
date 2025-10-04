# Social Media Feed Implementation

A modern, Twitter/Threads-inspired social media feed built with Flutter, featuring both light and dark mode support.

## 🎨 Features

### Core Features
- **Modern Social Media Design**: Clean, minimal interface inspired by Twitter and Threads
- **Light & Dark Mode**: Automatic theme switching based on system settings
- **Responsive Layout**: Optimized for mobile devices with proper spacing and typography
- **Interactive Post Cards**: Each post includes user avatar, username, handle, timestamp, content, and actions

### Post Card Components
- **User Avatar**: Circular profile image with fallback to initials
- **User Information**: Username and handle (@username)
- **Timestamp**: Relative time display (e.g., "5m ago", "2h ago")
- **Content**: Text content with proper line spacing
- **Images**: Optional 16:9 aspect ratio images with proper loading states
- **Action Bar**: Like, comment, retweet, bookmark, and share buttons

### Advanced Features
- **Animated Like Button**: Scale animation on tap with heart icon
- **Pull-to-Refresh**: Swipe down to refresh the feed
- **Loading States**: Shimmer effect while loading content
- **Floating Compose Button**: Animated FAB for creating new posts
- **Smooth Scrolling**: Optimized ListView with proper performance

## 🎯 Design Specifications

### Color Scheme
- **Light Mode**: 
  - Background: #FFFFFF
  - Text: #111827
  - Accent: #1DA1F2 (Twitter Blue)
- **Dark Mode**: 
  - Background: #0F1419
  - Text: #E5E7EB
  - Accent: #1DA1F2 (Twitter Blue)

### Typography
- **Font**: Inter (Google Fonts)
- **Weights**: Regular, Medium, Semi-bold, Bold
- **Sizes**: 12px to 32px with proper hierarchy

### Layout
- **Border Radius**: 16px for cards, 12px for images
- **Spacing**: 16px margins, 12px padding
- **Shadows**: Subtle elevation with proper contrast

## 📁 File Structure

```
lib/
├── core/theme/
│   └── app_theme.dart              # Light and dark theme definitions
├── data/models/
│   └── social_post_model.dart      # Post data model with all fields
├── presentation/
│   ├── screens/
│   │   ├── feed/
│   │   │   └── social_feed_screen.dart    # Main feed screen
│   │   └── demo/
│   │       └── social_feed_demo.dart      # Demo wrapper with theme toggle
│   └── widgets/
│       └── social_post_card.dart          # Individual post card widget
└── main_social_demo.dart                  # Demo entry point
```

## 🚀 How to Run

### Option 1: Run the Demo
```bash
flutter run lib/main_social_demo.dart
```

### Option 2: Integrate into Existing App
1. Copy the theme files to your existing theme
2. Add the social post model to your data models
3. Include the social feed screen in your navigation
4. Update your main.dart to include dark theme support

## 🔧 Dependencies

The implementation uses these key packages:
- `flutter_riverpod`: State management
- `google_fonts`: Typography (Inter font)
- `cached_network_image`: Image loading and caching
- `shimmer`: Loading animations (optional)

## 📱 Sample Data

The demo includes 4 sample posts with:
- Different user profiles and avatars
- Varied content (text-only and with images)
- Realistic timestamps and engagement metrics
- Proper user handles and usernames

## 🎨 Customization

### Adding New Post Actions
1. Update the `SocialPostModel` to include new fields
2. Add new action buttons to the `SocialPostCard`
3. Implement the corresponding callbacks

### Modifying Colors
1. Update the color constants in `app_theme.dart`
2. Ensure proper contrast ratios for accessibility
3. Test in both light and dark modes

### Changing Typography
1. Modify the text theme in `app_theme.dart`
2. Update font weights and sizes as needed
3. Ensure readability across different screen sizes

## 🔮 Future Enhancements

- **Real-time Updates**: WebSocket integration for live feed updates
- **Infinite Scroll**: Pagination for large datasets
- **Media Support**: Video posts and image galleries
- **Advanced Interactions**: Thread replies and quote tweets
- **Accessibility**: Screen reader support and high contrast mode
- **Performance**: Image optimization and lazy loading

## 📄 License

This implementation is part of the AutoHub project and follows the same licensing terms.

## 🤝 Contributing

When contributing to this social feed implementation:
1. Maintain the existing design language
2. Ensure both light and dark mode compatibility
3. Test on different screen sizes
4. Follow Flutter best practices
5. Update documentation as needed

---

**Note**: This is a demo implementation showcasing modern social media UI patterns. For production use, integrate with your backend API and implement proper data persistence.





