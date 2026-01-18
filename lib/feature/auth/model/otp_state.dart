enum OtpStatus {
  idle,
  sending,
  sent,
  verifying,
  success,
  failure,
}

class OtpAuthState {
  final OtpStatus status;
  final String? mobile;
  final String? error;
  final DateTime? expiresAt;
  final int resendCount;

  const OtpAuthState({
    required this.status,
    this.mobile,
    this.error,
    this.expiresAt,
    this.resendCount = 0,
  });

  factory OtpAuthState.initial() {
    return const OtpAuthState(status: OtpStatus.idle);
  }

  OtpAuthState copyWith({
    OtpStatus? status,
    String? mobile,
    String? error,
    DateTime? expiresAt,
    int? resendCount,
  }) {
    return OtpAuthState(
      status: status ?? this.status,
      mobile: mobile ?? this.mobile,
      error: error,
      expiresAt: expiresAt ?? this.expiresAt,
      resendCount: resendCount ?? this.resendCount,
    );
  }

  bool get isLoading => status == OtpStatus.sending || status == OtpStatus.verifying;
  bool get isError => status == OtpStatus.failure;
  bool get isSuccess => status == OtpStatus.success;
}
