import 'package:web_dex/bloc/analytics/analytics_repo.dart';

final WalletsManagerEventsFactory walletsManagerEventsFactory =
    WalletsManagerEventsFactory();

class WalletsManagerEventsFactory {
  AnalyticsEventData createEvent(
      WalletsManagerEventType type, WalletsManagerEventMethod method) {
    return WalletsManagerEvent(
      name: 'login',
      source: type.name,
      method: method.name,
    );
  }
}

enum WalletsManagerEventType {
  header,
  wallet,
  fiat,
  dex,
  nft,
  bridge;
}

enum WalletsManagerEventMethod {
  create,
  import,
  loginExisting,
  nft,
  hardware;
}

class WalletsManagerEvent extends AnalyticsEventData {
  final String source;
  final String method;

  WalletsManagerEvent({
    required String name,
    required this.source,
    required this.method,
  }) {
    this.name = name;
  }

  @override
  Map<String, dynamic> get parameters => {
        'source': source,
        'method': method,
      };
}
