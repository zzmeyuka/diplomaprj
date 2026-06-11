# SmartFly

Mobile flight ticket metasearch and recommendation application for Kazakhstan.

Compare offers from **Kaspi Travel**, **Freedom Travel**, **Tickets.kz**, and **Trip**.

## Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter + Dart (Provider) |
| API | Node.js + Express |
| ORM | Prisma |
| Database | PostgreSQL |
| AI chatbot | Google Gemini |
| Auth | JWT + bcryptjs |

## Project structure

```
diplomaprj/
├── backend/          # Express API + Prisma
├── mobile/           # Flutter app
└── README.md
```

## 1. PostgreSQL

Install PostgreSQL locally and create the database:

```sql
CREATE DATABASE diploma;
```

## 2. Backend setup

```bash
cd backend
```

Create `backend/.env`:

```env
DATABASE_URL="postgresql://postgres:1234@localhost:5432/smartfly_db?schema=public"
PORT=3000
JWT_SECRET=smartfly_super_secret_key
JWT_EXPIRES_IN=7d
GEMINI_API_KEY=
GEMINI_MODEL=gemini-2.5-flash
```

Install and sync schema:

```bash
npm install
npx prisma generate
npx prisma db push
```

> **Note:** If an old incompatible schema exists, reset the dev database (deletes all data):
>
> ```bash
> npx prisma db push --force-reset
> ```
>
> Only use this on local development databases.

Seed (~600k flight offers, may take 10–30+ minutes):

```bash
npx prisma db seed
```

Start API:

```bash
npm run dev
```

API base: `http://localhost:3000/api`

### Seeded accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@smartfly.kz | admin123 |
| User | user@gmail.com | 123456 |

## 3. Flutter app

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter run
```

API URL (`mobile/lib/core/constants/api_config.dart`):

- Android emulator: `http://10.0.2.2:3000/api`
- Desktop / iOS simulator: `http://localhost:3000/api`

## API testing examples

Replace `TOKEN` with JWT from login.

```bash
# Health / DB
curl http://localhost:3000/api/test-db
curl http://localhost:3000/api/cities

# Auth
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"fullName\":\"User Name\",\"email\":\"test@test.com\",\"password\":\"123456\"}"

curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"user@gmail.com\",\"password\":\"123456\"}"

curl http://localhost:3000/api/auth/me -H "Authorization: Bearer TOKEN"

# Flights
curl "http://localhost:3000/api/flights/search?from=Almaty&to=Bishkek&date=2026-06-20&cabinClass=economy&passengers=3"

curl "http://localhost:3000/api/flights/cheapest?from=Almaty&to=Bishkek&date=2026-06-20&cabinClass=business&passengers=2"

# Favorites (auth required)
curl -X POST http://localhost:3000/api/favorites \
  -H "Authorization: Bearer TOKEN" -H "Content-Type: application/json" \
  -d "{\"flightOfferId\":\"FLIGHT_UUID\"}"

curl http://localhost:3000/api/favorites -H "Authorization: Bearer TOKEN"

# Bookings
curl -X POST http://localhost:3000/api/bookings \
  -H "Authorization: Bearer TOKEN" -H "Content-Type: application/json" \
  -d "{\"flightOfferId\":\"FLIGHT_UUID\",\"passengersCount\":2}"

curl http://localhost:3000/api/bookings/my -H "Authorization: Bearer TOKEN"

# Recommendations
curl "http://localhost:3000/api/recommendations?passengers=2" -H "Authorization: Bearer TOKEN"

# Chat
curl -X POST http://localhost:3000/api/chat/ask \
  -H "Authorization: Bearer TOKEN" -H "Content-Type: application/json" \
  -d "{\"message\":\"Какой билет самый выгодный?\",\"from\":\"Almaty\",\"to\":\"Bishkek\",\"date\":\"2026-06-20\",\"cabinClass\":\"economy\",\"passengers\":3}"

# Admin
curl http://localhost:3000/api/admin/stats -H "Authorization: Bearer ADMIN_TOKEN"
curl http://localhost:3000/api/admin/users -H "Authorization: Bearer ADMIN_TOKEN"
```

## Gemini chatbot

Add key to `backend/.env`:

```env
GEMINI_API_KEY=your_key_here
```


