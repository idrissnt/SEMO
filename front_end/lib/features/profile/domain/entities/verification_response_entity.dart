/// Entity representing a verification response from the backend
class VerificationResponse {
  final String message;
  final String requestId;
  final bool success;

  const VerificationResponse({
    required this.message,
    required this.requestId,
    this.success = true,
  });
}
