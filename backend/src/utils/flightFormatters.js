function formatDuration(minutes) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  if (h === 0) return `${m}m`;
  if (m === 0) return `${h}h`;
  return `${h}h ${m}m`;
}

function calcFinalPrice(basePrice, discountPercent) {
  const base = Number(basePrice);
  const discount = Number(discountPercent) || 0;
  return Math.round(base * (100 - discount) / 100);
}

function mapFlightOffer(offer, passengers = 1) {
  const finalPrice = Number(offer.finalPrice);
  const pricePerPassenger = finalPrice;
  const passengersCount = Number(passengers) || 1;
  return {
    id: offer.id,
    flightCode: offer.flightCode,
    routeId: offer.routeId,
    aggregatorId: offer.aggregatorId,
    aggregatorName: offer.aggregator?.name ?? offer.aggregatorName,
    originCity: offer.route?.originCity?.nameEn ?? offer.originCity,
    destinationCity: offer.route?.destinationCity?.nameEn ?? offer.destinationCity,
    departureAt: offer.departureAt,
    arrivalAt: offer.arrivalAt,
    durationMinutes: offer.durationMinutes,
    formattedDuration: formatDuration(offer.durationMinutes),
    cabinClass: offer.cabinClass,
    basePrice: Number(offer.basePrice),
    discountPercent: offer.discountPercent,
    finalPrice,
    pricePerPassenger,
    passengersCount,
    totalPrice: finalPrice * passengersCount,
    currency: offer.currency,
    seatsLeft: offer.seatsLeft,
    baggageIncluded: offer.baggageIncluded,
    refundable: offer.refundable,
    transferType: offer.transferType,
    status: offer.status,
  };
}

const flightInclude = {
  aggregator: true,
  route: {
    include: {
      originCity: true,
      destinationCity: true,
    },
  },
};

module.exports = {
  formatDuration,
  calcFinalPrice,
  mapFlightOffer,
  flightInclude,
};
