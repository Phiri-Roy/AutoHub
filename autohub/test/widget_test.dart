// AutoHub Widget Tests
//
// This file contains tests for the AutoHub car enthusiast community app.
// Tests cover the main app structure and key widgets.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autohub/main.dart';
import 'package:autohub/presentation/screens/auth/login_screen.dart';
import 'package:autohub/presentation/screens/auth/register_screen.dart';

void main() {
  group('AutoHub App Tests', () {
    testWidgets('App loads without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: AutoHubApp()));

      // Verify that the app loads without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login screen has correct elements', (WidgetTester tester) async {
      // Build the login screen directly
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that we see the login screen elements
      expect(find.text('Welcome to AutoHub'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Login form has required fields', (WidgetTester tester) async {
      // Build the login screen directly
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that login form fields are present
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Register screen has correct elements', (WidgetTester tester) async {
      // Build the register screen directly
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that we're on the register screen
      expect(find.text('Join AutoHub'), findsOneWidget);
      expect(find.text('Create your account to get started'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsNWidgets(2)); // AppBar and main button
    });

    testWidgets('Register form has all required fields', (WidgetTester tester) async {
      // Build the register screen directly
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify that register form fields are present
      expect(find.byType(TextFormField), findsNWidgets(4)); // Username, Email, Password, Confirm Password
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsNWidgets(2)); // AppBar and main button
    });

    testWidgets('Navigation between login and register works', (WidgetTester tester) async {
      // Start with login screen
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.text('Welcome to AutoHub'), findsOneWidget);

      // Navigate to register screen
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify that we're on the register screen
      expect(find.text('Join AutoHub'), findsOneWidget);
      expect(find.text('Create your account to get started'), findsOneWidget);
    });
  });
}
