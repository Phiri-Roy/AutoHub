import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../feed/social_feed_screen.dart';

class SocialFeedDemo extends StatefulWidget {
  const SocialFeedDemo({super.key});

  @override
  State<SocialFeedDemo> createState() => _SocialFeedDemoState();
}

class _SocialFeedDemoState extends State<SocialFeedDemo> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Feed Demo',
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: Column(
          children: [
            // Demo header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? AppTheme.darkSurface
                    : AppTheme.lightSurface,
                border: Border(
                  bottom: BorderSide(
                    color: _isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: _isDarkMode
                            ? AppTheme.darkTextPrimary
                            : AppTheme.lightTextPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Social Feed Demo',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: _isDarkMode
                            ? AppTheme.darkTextPrimary
                            : AppTheme.lightTextPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Social feed
            Expanded(child: SocialFeedScreen()),
          ],
        ),
      ),
    );
  }
}
























