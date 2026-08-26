# Finora 💸

> A smart budget tracker application — built with Flutter (mobile) and Node.js (API).

## Monorepo Structure

```
finora/
├── mobile/     # Flutter app (Android / iOS)
└── api/        # Node.js + Express + Prisma REST API
```

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.32
- Node.js ≥ 20
- Java 17
- Android SDK (platform 35)

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

### API
```bash
cd api
npm install
cp .env.example .env
npx prisma migrate dev
npm run dev
```

## Features
- 🏦 Multiple account management
- 💳 Income & expense tracking
- 📊 Budget goals & analytics
- 📅 Transaction history with filters
- 🔐 JWT authentication
