class UnsettledDebt {
  final String tripId;
  final String tripName;
  final DateTime tripDate;
  final String passengerName;
  final double amountOwed;

  UnsettledDebt({
    required this.tripId,
    required this.tripName,
    required this.tripDate,
    required this.passengerName,
    required this.amountOwed,
  });
}