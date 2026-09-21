class LogContext {
  final String? userId;
  final String? sessionId;
  final String? screen;
  final String? appVersion;
  final String? platform;
  final String? deviceModel;

  const LogContext({
    this.userId,
    this.sessionId,
    this.screen,
    this.appVersion,
    this.platform,
    this.deviceModel,
  });

  LogContext copyWith({
    String? userId,
    bool clearUserId = false,
    String? sessionId,
    String? screen,
    String? appVersion,
    String? platform,
    String? deviceModel,
  }) =>
      LogContext(
        userId: clearUserId ? null : (userId ?? this.userId),
        sessionId: sessionId ?? this.sessionId,
        screen: screen ?? this.screen,
        appVersion: appVersion ?? this.appVersion,
        platform: platform ?? this.platform,
        deviceModel: deviceModel ?? this.deviceModel,
      );

  Map<String, dynamic> toMap() => {
        if (userId != null) 'userId': userId,
        if (sessionId != null) 'sessionId': sessionId,
        if (screen != null) 'screen': screen,
        if (appVersion != null) 'appVersion': appVersion,
        if (platform != null) 'platform': platform,
        if (deviceModel != null) 'deviceModel': deviceModel,
      };
}
