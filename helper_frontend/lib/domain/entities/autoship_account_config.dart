import 'dart:convert';

class AutoShipAccountConfig {
  final int processId;

  const AutoShipAccountConfig({required this.processId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'processId': processId};
  }

  String toJson() => json.encode(toMap());
}
