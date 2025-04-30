/// Entity representing a verification response from the backend
class VerificationResponse {
  final String message;
  final String requestId;

  const VerificationResponse({
    required this.message,
    required this.requestId,
  });
}
