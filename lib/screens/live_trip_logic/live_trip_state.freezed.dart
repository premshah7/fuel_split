// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_trip_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LiveTripState _$LiveTripStateFromJson(Map<String, dynamic> json) {
  return _LiveTripState.fromJson(json);
}

/// @nodoc
mixin _$LiveTripState {
  bool get isTracking => throw _privateConstructorUsedError;
  double get totalDistance => throw _privateConstructorUsedError;
  String get startAddress => throw _privateConstructorUsedError;

  /// Serializes this LiveTripState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveTripState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveTripStateCopyWith<LiveTripState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveTripStateCopyWith<$Res> {
  factory $LiveTripStateCopyWith(
    LiveTripState value,
    $Res Function(LiveTripState) then,
  ) = _$LiveTripStateCopyWithImpl<$Res, LiveTripState>;
  @useResult
  $Res call({bool isTracking, double totalDistance, String startAddress});
}

/// @nodoc
class _$LiveTripStateCopyWithImpl<$Res, $Val extends LiveTripState>
    implements $LiveTripStateCopyWith<$Res> {
  _$LiveTripStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveTripState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isTracking = null,
    Object? totalDistance = null,
    Object? startAddress = null,
  }) {
    return _then(
      _value.copyWith(
            isTracking: null == isTracking
                ? _value.isTracking
                : isTracking // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalDistance: null == totalDistance
                ? _value.totalDistance
                : totalDistance // ignore: cast_nullable_to_non_nullable
                      as double,
            startAddress: null == startAddress
                ? _value.startAddress
                : startAddress // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiveTripStateImplCopyWith<$Res>
    implements $LiveTripStateCopyWith<$Res> {
  factory _$$LiveTripStateImplCopyWith(
    _$LiveTripStateImpl value,
    $Res Function(_$LiveTripStateImpl) then,
  ) = __$$LiveTripStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isTracking, double totalDistance, String startAddress});
}

/// @nodoc
class __$$LiveTripStateImplCopyWithImpl<$Res>
    extends _$LiveTripStateCopyWithImpl<$Res, _$LiveTripStateImpl>
    implements _$$LiveTripStateImplCopyWith<$Res> {
  __$$LiveTripStateImplCopyWithImpl(
    _$LiveTripStateImpl _value,
    $Res Function(_$LiveTripStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiveTripState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isTracking = null,
    Object? totalDistance = null,
    Object? startAddress = null,
  }) {
    return _then(
      _$LiveTripStateImpl(
        isTracking: null == isTracking
            ? _value.isTracking
            : isTracking // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalDistance: null == totalDistance
            ? _value.totalDistance
            : totalDistance // ignore: cast_nullable_to_non_nullable
                  as double,
        startAddress: null == startAddress
            ? _value.startAddress
            : startAddress // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveTripStateImpl implements _LiveTripState {
  const _$LiveTripStateImpl({
    this.isTracking = false,
    this.totalDistance = 0.0,
    this.startAddress = 'Press Start to begin your trip',
  });

  factory _$LiveTripStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveTripStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isTracking;
  @override
  @JsonKey()
  final double totalDistance;
  @override
  @JsonKey()
  final String startAddress;

  @override
  String toString() {
    return 'LiveTripState(isTracking: $isTracking, totalDistance: $totalDistance, startAddress: $startAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveTripStateImpl &&
            (identical(other.isTracking, isTracking) ||
                other.isTracking == isTracking) &&
            (identical(other.totalDistance, totalDistance) ||
                other.totalDistance == totalDistance) &&
            (identical(other.startAddress, startAddress) ||
                other.startAddress == startAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isTracking, totalDistance, startAddress);

  /// Create a copy of LiveTripState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveTripStateImplCopyWith<_$LiveTripStateImpl> get copyWith =>
      __$$LiveTripStateImplCopyWithImpl<_$LiveTripStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveTripStateImplToJson(this);
  }
}

abstract class _LiveTripState implements LiveTripState {
  const factory _LiveTripState({
    final bool isTracking,
    final double totalDistance,
    final String startAddress,
  }) = _$LiveTripStateImpl;

  factory _LiveTripState.fromJson(Map<String, dynamic> json) =
      _$LiveTripStateImpl.fromJson;

  @override
  bool get isTracking;
  @override
  double get totalDistance;
  @override
  String get startAddress;

  /// Create a copy of LiveTripState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveTripStateImplCopyWith<_$LiveTripStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
