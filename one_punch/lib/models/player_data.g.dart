// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerDataAdapter extends TypeAdapter<PlayerData> {
  @override
  final int typeId = 0;

  @override
  PlayerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerData(
      nickname:               fields[0]  as String,
      coins:                  fields[1]  as int,
      gems:                   fields[2]  as int,
      stamina:                fields[3]  as int,
      lastStaminaTime:        fields[4]  as DateTime,
      atkLevel:               fields[5]  as int,
      spdLevel:               fields[6]  as int,
      comboLevel:             fields[7]  as int,
      hpLevel:                fields[8]  as int,
      highestStage:           fields[9]  as int,
      maxCombo:               fields[10] as int,
      selectedCharacterIndex: fields[11] as int,
      unlockedCharacters:     (fields[12] as List).cast<int>(),
      totalGamesPlayed:       fields[13] as int,
      totalPerfectCount:      fields[14] as int,
      dailyAdWatchCount:      fields[15] as int,
      lastAdDate:             fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerData obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)  ..write(obj.nickname)
      ..writeByte(1)  ..write(obj.coins)
      ..writeByte(2)  ..write(obj.gems)
      ..writeByte(3)  ..write(obj.stamina)
      ..writeByte(4)  ..write(obj.lastStaminaTime)
      ..writeByte(5)  ..write(obj.atkLevel)
      ..writeByte(6)  ..write(obj.spdLevel)
      ..writeByte(7)  ..write(obj.comboLevel)
      ..writeByte(8)  ..write(obj.hpLevel)
      ..writeByte(9)  ..write(obj.highestStage)
      ..writeByte(10) ..write(obj.maxCombo)
      ..writeByte(11) ..write(obj.selectedCharacterIndex)
      ..writeByte(12) ..write(obj.unlockedCharacters)
      ..writeByte(13) ..write(obj.totalGamesPlayed)
      ..writeByte(14) ..write(obj.totalPerfectCount)
      ..writeByte(15) ..write(obj.dailyAdWatchCount)
      ..writeByte(16) ..write(obj.lastAdDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
