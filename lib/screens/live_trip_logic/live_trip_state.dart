import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_trip_state.freezed.dart';
part 'live_trip_state.g.dart';

@freezed
class LiveTripState with _$LiveTripState {
  const factory LiveTripState({
    @Default(false) bool isTracking,
    @Default(0.0) double totalDistance,
    @Default('Press Start to begin your trip') String startAddress,
  }) = _LiveTripState;

  factory LiveTripState.fromJson(Map<String, dynamic> json) =>
      _$LiveTripStateFromJson(json);
}