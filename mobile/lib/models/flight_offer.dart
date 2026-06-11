class FlightOffer {
  final String id;
  final String flightCode;
  final String? aggregatorName;
  final String? originCity;
  final String? destinationCity;
  final DateTime departureAt;
  final DateTime arrivalAt;
  final int durationMinutes;
  final String formattedDuration;
  final String cabinClass;
  final double finalPrice;
  final double pricePerPassenger;
  final int passengersCount;
  final double totalPrice;
  final String currency;
  final int seatsLeft;
  final bool baggageIncluded;
  final bool refundable;
  final String transferType;
  final String status;
  final int? discountPercent;
  final String? reason;

  FlightOffer({
    required this.id,
    required this.flightCode,
    this.aggregatorName,
    this.originCity,
    this.destinationCity,
    required this.departureAt,
    required this.arrivalAt,
    required this.durationMinutes,
    required this.formattedDuration,
    required this.cabinClass,
    required this.finalPrice,
    required this.pricePerPassenger,
    required this.passengersCount,
    required this.totalPrice,
    required this.currency,
    required this.seatsLeft,
    required this.baggageIncluded,
    required this.refundable,
    required this.transferType,
    required this.status,
    this.discountPercent,
    this.reason,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      id: json['id'] as String,
      flightCode: json['flightCode'] as String,
      aggregatorName: json['aggregatorName'] as String?,
      originCity: json['originCity'] as String?,
      destinationCity: json['destinationCity'] as String?,
      departureAt: DateTime.parse(json['departureAt'] as String),
      arrivalAt: DateTime.parse(json['arrivalAt'] as String),
      durationMinutes: json['durationMinutes'] as int,
      formattedDuration: json['formattedDuration'] as String? ?? '',
      cabinClass: json['cabinClass'] as String,
      finalPrice: (json['finalPrice'] as num).toDouble(),
      pricePerPassenger: (json['pricePerPassenger'] as num).toDouble(),
      passengersCount: json['passengersCount'] as int? ?? 1,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KZT',
      seatsLeft: json['seatsLeft'] as int,
      baggageIncluded: json['baggageIncluded'] as bool,
      refundable: json['refundable'] as bool,
      transferType: json['transferType'] as String,
      status: json['status'] as String? ?? 'available',
      discountPercent: json['discountPercent'] as int?,
      reason: json['reason'] as String?,
    );
  }
}
