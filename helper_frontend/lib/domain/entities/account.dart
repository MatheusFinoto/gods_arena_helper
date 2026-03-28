// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:helper_frontend/core/enums/faction_enum.dart';

class Account {
  final int processId;
  final String nick;
  final FactionEnum faction;

  Account({
    required this.processId,
    required this.nick,
    required this.faction,
  });

  Account copyWith({int? processId, String? nick, FactionEnum? faction}) {
    return Account(
      processId: processId ?? this.processId,
      nick: nick ?? this.nick,
      faction: faction ?? this.faction,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'processId': processId,
      'nick': nick,
      'faction': faction.name,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      processId: map['processId'] as int,
      nick: map['nick'] as String,
      faction: FactionEnumExtension.fromString(map['faction'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source) =>
      Account.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Account(processId: $processId, nick: $nick, faction: $faction)';

  @override
  bool operator ==(covariant Account other) {
    if (identical(this, other)) return true;

    return other.processId == processId &&
        other.nick == nick &&
        other.faction == faction;
  }

  @override
  int get hashCode => processId.hashCode ^ nick.hashCode ^ faction.hashCode;
}
