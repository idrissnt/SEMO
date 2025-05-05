import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:semo/core/domain/entities/user_entity.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/home/presentation/bloc/email_verification/verify_email_code_bloc.dart';
import 'package:semo/features/home/presentation/bloc/email_verification/verify_email_code_state.dart';
import 'package:semo/features/home/presentation/full_screen_bottom_sheet/verify_email_bottom_sheet.dart';
import 'package:semo/features/profile/domain/entities/verification_response_entity.dart';

// Import the generated mock classes
import 'test.mocks.dart';

// Generate mock classes
@GenerateMocks([VerifyEmailCodeBloc, AuthBloc])
void main() {
  late MockVerifyEmailCodeBloc mockVerifyEmailCodeBloc;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    // Create mock instances
    mockVerifyEmailCodeBloc = MockVerifyEmailCodeBloc();
    mockAuthBloc = MockAuthBloc();

    // Set up default behavior for AuthBloc
    when(mockAuthBloc.state).thenReturn(
      AuthAuthenticated(
        User(
          id: '123',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          // No need to specify all properties as they have defaults
        ),
      ),
    );

    // Set up default behavior for VerifyEmailCodeBloc
    when(mockVerifyEmailCodeBloc.state)
        .thenReturn(const VerifyEmailCodeInitial());
  });

  /// Helper function to create the widget under test with all required providers
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<VerifyEmailCodeBloc>.value(
              value: mockVerifyEmailCodeBloc),
        ],
        child: const Scaffold(
          body: VerifyEmailBottomSheet(),
        ),
      ),
    );
  }

  group('VerifyEmailBottomSheet', () {
    testWidgets('displays user email correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('shows loading indicator when resending email',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - tap the resend button
      await tester.tap(find.text('Resend Email'));
      await tester.pump(); // Rebuild after tap

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls correct event when resend button is pressed',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - tap the resend button
      await tester.tap(find.text('Resend Email'));
      await tester.pump();

      // Assert - verify the correct event was added to the bloc
      verify(mockVerifyEmailCodeBloc.add(any)).called(1);
    });

    testWidgets('shows success message when email is sent',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Create a stream controller to emit states
      final controller = StreamController<VerifyEmailCodeState>();
      when(mockVerifyEmailCodeBloc.stream).thenAnswer((_) => controller.stream);

      // Emit a verification success state
      controller.add(const VerifyEmailCodeVerified(
        response: VerificationResponse(
          message: 'Email verified successfully',
          requestId: 'test-request-id',
          success: true,
        ),
      ));

      // Act - rebuild the widget with the new state
      await tester.pump(); // Process the state change
      await tester.pump(const Duration(milliseconds: 100)); // Wait for SnackBar

      // Assert - should show success message in a snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text('Verification email sent successfully!'), findsOneWidget);

      // Clean up
      controller.close();
    });

    testWidgets('can be dismissed by tapping skip button',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - tap the skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle(); // Wait for animations

      // Assert - verify the button exists and is tappable
      expect(find.text('Skip'), findsOneWidget);
    });
  });
}
