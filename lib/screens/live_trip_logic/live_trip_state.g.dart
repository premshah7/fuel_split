// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_trip_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveTripStateImpl _$$LiveTripStateImplFromJson(Map<String, dynamic> json) =>
    _$LiveTripStateImpl(
      isTracking: json['isTracking'] as bool? ?? false,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      startAddress:
          json['startAddress'] as String? ?? 'Press Start to begin your trip',
    );

Map<String, dynamic> _$$LiveTripStateImplToJson(_$LiveTripStateImpl instance) =>
    <String, dynamic>{
      'isTracking': instance.isTracking,
      'totalDistance': instance.totalDistance,
      'startAddress': instance.startAddress,
    };
