const FLIGHT_TIMES = ["07:20", "11:30", "16:45", "21:10"];
const CABIN_CLASSES = ["economy", "comfort", "business"];
const START_DATE = new Date("2026-06-01T00:00:00.000Z");
const END_DATE = new Date("2026-08-31T00:00:00.000Z");

const AGGREGATORS = [
  { name: "Kaspi Travel", multiplier: 1.0 },
  { name: "Freedom Travel", multiplier: 0.97 },
  { name: "Tickets.kz", multiplier: 1.04 },
  { name: "Trip", multiplier: 0.96 },
];

const DOMESTIC_CITIES = [
  "Almaty", "Astana", "Shymkent", "Aktau", "Atyrau", "Aktobe", "Karaganda",
  "Pavlodar", "Semey", "Oskemen", "Kostanay", "Kyzylorda", "Turkestan",
  "Uralsk", "Taraz", "Taldykorgan", "Baikonur",
];

const INTERNATIONAL_CITIES = [
  "Istanbul", "Antalya", "Dubai", "Beijing", "Seoul", "Bangkok", "Phuket",
  "Tbilisi", "Kuala Lumpur", "Moscow", "Bishkek", "Sharm El Sheikh", "Amsterdam",
];

const INTERNATIONAL_ROUTES = [
  ["Almaty", ["Istanbul", "Antalya", "Dubai", "Beijing", "Seoul", "Bangkok", "Phuket", "Tbilisi", "Kuala Lumpur", "Moscow", "Bishkek"]],
  ["Astana", ["Istanbul", "Antalya", "Dubai", "Beijing", "Seoul", "Bangkok", "Tbilisi", "Kuala Lumpur", "Moscow", "Bishkek"]],
  ["Shymkent", ["Istanbul", "Antalya", "Dubai", "Sharm El Sheikh", "Kuala Lumpur", "Moscow", "Bishkek"]],
  ["Aktau", ["Istanbul", "Antalya", "Tbilisi", "Moscow"]],
  ["Atyrau", ["Istanbul", "Antalya", "Dubai", "Amsterdam", "Moscow"]],
  ["Aktobe", ["Istanbul", "Antalya", "Dubai"]],
  ["Karaganda", ["Moscow"]],
  ["Oskemen", ["Moscow"]],
  ["Kostanay", ["Moscow"]],
];

const DOMESTIC_HUBS = [
  "Almaty", "Astana", "Shymkent", "Aktobe", "Karaganda", "Taraz", "Pavlodar",
  "Semey", "Oskemen", "Aktau", "Atyrau", "Kyzylorda", "Uralsk", "Turkestan",
  "Taldykorgan", "Kostanay",
];

function priceRangeForRoute(origin, dest) {
  if (origin === "Kyzylorda" && dest === "Baikonur") return [8000, 18000];
  if (
    (origin === "Almaty" && dest === "Astana") ||
    (origin === "Astana" && dest === "Almaty")
  ) return [24000, 38000];
  const intlDests = INTERNATIONAL_CITIES;
  const isIntl = intlDests.includes(dest) || intlDests.includes(origin);
  if (isIntl) {
    if (dest === "Bishkek" || origin === "Bishkek") return [35000, 65000];
    if (dest === "Moscow" || origin === "Moscow") return [70000, 130000];
    if (dest === "Tbilisi" || origin === "Tbilisi") return [75000, 140000];
    if (dest === "Istanbul" || dest === "Antalya" || origin === "Istanbul" || origin === "Antalya") return [95000, 170000];
    if (dest === "Dubai" || origin === "Dubai") return [100000, 180000];
    if (dest === "Beijing" || dest === "Seoul" || origin === "Beijing" || origin === "Seoul") return [140000, 260000];
    if (["Bangkok", "Phuket", "Kuala Lumpur"].includes(dest) || ["Bangkok", "Phuket", "Kuala Lumpur"].includes(origin)) return [160000, 320000];
    if (dest === "Amsterdam" || origin === "Amsterdam") return [200000, 380000];
    if (dest === "Sharm El Sheikh") return [120000, 200000];
    return [90000, 160000];
  }
  const longDomestic = ["Aktau", "Atyrau"];
  if (longDomestic.includes(dest) || longDomestic.includes(origin)) return [45000, 85000];
  return [26000, 55000];
}

function randomBetween(min, max) {
  return Math.floor(min + Math.random() * (max - min + 1));
}

function cabinMultiplier(cabin) {
  if (cabin === "economy") return 1;
  if (cabin === "comfort") return 1.35 + Math.random() * 0.25;
  return 2.2 + Math.random() * 0.8;
}

function eachDate(start, end) {
  const dates = [];
  const d = new Date(start);
  while (d <= end) {
    dates.push(new Date(d));
    d.setUTCDate(d.getUTCDate() + 1);
  }
  return dates;
}

function buildDomesticRoutePairs() {
  const pairs = [];
  const hubs = DOMESTIC_HUBS;
  for (let i = 0; i < hubs.length; i++) {
    for (let j = 0; j < hubs.length; j++) {
      if (i === j) continue;
      pairs.push([hubs[i], hubs[j]]);
    }
  }
  pairs.push(["Kyzylorda", "Baikonur"], ["Baikonur", "Kyzylorda"]);
  return pairs;
}

function buildAllRoutePairs() {
  const domestic = buildDomesticRoutePairs();
  const international = [];
  for (const [origin, dests] of INTERNATIONAL_ROUTES) {
    for (const dest of dests) {
      international.push([origin, dest]);
    }
  }
  return { domestic, international };
}

module.exports = {
  FLIGHT_TIMES,
  CABIN_CLASSES,
  START_DATE,
  END_DATE,
  AGGREGATORS,
  DOMESTIC_CITIES,
  INTERNATIONAL_CITIES,
  buildAllRoutePairs,
  priceRangeForRoute,
  randomBetween,
  cabinMultiplier,
  eachDate,
};
