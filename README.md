# Qelio — Quote of the Day

> *Wisdom, reimagined.* One original, masterfully crafted insight delivered to you every single day.

---

## Overview

**Qelio** is a premium daily quote app built with **Flutter** (frontend) and **Node.js + Express** (backend), powered by **Google Gemini AI** for original quote generation. It features a personalized onboarding wizard, daily streak tracking, quote history, favorites, and scheduled push notifications — all wrapped in a minimal, award-winning design aesthetic.

---

## Features

| Feature | Description |
|---|---|
| 🤖 **AI-Generated Quotes** | Original quotes crafted by Google Gemini with a creative copywriter persona — no clichés, no fortune-cookie platitudes |
| 🎯 **Personalized Preferences** | 5-step immersive onboarding wizard to configure goal, tone, themes, length, language and delivery time |
| 🔥 **Daily Streaks** | Backend-tracked persistent streak counter with milestone celebrations at 3, 7, 14, 30 and 100 days |
| 📜 **Quote History** | Full archive of your past quotes with category filter chips |
| ❤️ **Favorites** | Save and manage a personal curated collection of quotes |
| 🔔 **Push Notifications** | Scheduled daily delivery via `flutter_local_notifications` |
| ♻️ **Regenerate** | One-time daily regeneration to get a fresh perspective |
| 🌙 **Dark / Light Mode** | Full dark mode with an editorial monochromatic gold palette |
| 🚦 **Rate Limiting** | Three-tiered express-rate-limit middleware to protect all API endpoints |
| 📡 **Offline Support** | SharedPreferences caching of quote, history and favorites for seamless offline reading |

---

## Tech Stack

### Frontend — Flutter
| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management (Clean Architecture) |
| `go_router` | Declarative routing |
| `dio` | HTTP client with interceptors |
| `shared_preferences` | Local persistence / offline cache |
| `google_fonts` | DM Sans + Playfair Display typography |
| `flutter_local_notifications` | Scheduled push notifications |
| `share_plus` | Native quote sharing |

### Backend — Node.js
| Package | Purpose |
|---|---|
| `express` | REST API server |
| `mongoose` | MongoDB ODM |
| `@google/generative-ai` | Gemini AI SDK for quote generation |
| `jsonwebtoken` | JWT authentication |
| `bcryptjs` | Password hashing |
| `express-rate-limit` | Tiered API rate limiting |
| `dotenv` | Environment configuration |
| `nodemon` | Development hot reload |

---

## Architecture

```
QuoteOfTheDay/
├── lib/
│   ├── core/
│   │   ├── constants/         # App colors, typography constants
│   │   ├── models/            # QuoteModel, data classes
│   │   ├── network/           # Dio client setup
│   │   ├── providers/         # Riverpod providers (quote, streak)
│   │   ├── routing/           # GoRouter configuration
│   │   ├── services/          # Notification service
│   │   ├── theme/             # Material 3 dark/light themes
│   │   └── widgets/           # Shared widgets (skeleton loader, etc.)
│   └── features/
│       ├── auth/              # Login, register, auth provider
│       ├── favorites/         # Favorites screen
│       ├── history/           # History screen with category filter
│       ├── home/              # Daily quote card screen
│       ├── notifications/     # Notifications settings screen
│       ├── onboarding/        # Animated onboarding screen
│       ├── profile/           # Profile + stats screen
│       └── questionnaire/     # 5-step preferences wizard
└── backend/
    ├── src/
    │   ├── controllers/       # quoteController, authController
    │   ├── middleware/        # authMiddleware, rateLimiter
    │   ├── models/            # User, DailyQuote, FavoriteQuote, Streak, Preference, QuotePool
    │   ├── routes/            # authRoutes, quoteRoutes
    │   └── services/          # geminiService (AI prompt engine)
    ├── server.js
    ├── seedQuotes.js          # Initial QuotePool seed data
    └── resetDb.js             # Database wipe utility
```

---

## API Endpoints

### Auth
| Method | Route | Description |
|---|---|---|
| `POST` | `/api/auth/register` | Register a new user |
| `POST` | `/api/auth/login` | Login and receive JWT |
| `GET` | `/api/auth/profile` | Get current user profile |

### Quotes *(all protected — requires Bearer token)*
| Method | Route | Description |
|---|---|---|
| `GET` | `/api/quotes/daily` | Get today's quote (cached or generated) |
| `POST` | `/api/quotes/regenerate` | Regenerate today's quote (once per day) |
| `GET` | `/api/quotes/history` | Get all past daily quotes |
| `GET` | `/api/quotes/streak` | Get current and longest streak |
| `GET` | `/api/quotes/favorites` | Get saved favorites |
| `POST` | `/api/quotes/favorites` | Save a quote to favorites |
| `DELETE` | `/api/quotes/favorites/:id` | Remove a favorite |

### Rate Limits
| Limiter | Scope | Limit |
|---|---|---|
| `apiLimiter` | All `/api` routes | 100 requests / 15 min |
| `authLimiter` | `/register`, `/login` | 10 requests / 15 min |
| `quoteLimiter` | `/daily`, `/regenerate` | 20 requests / hour |

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Node.js `>=18`
- MongoDB Atlas account (or local instance)
- Google Gemini API key

---

### Backend Setup

```bash
cd backend
npm install
```

Create a `.env` file in `backend/`:
```env
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
GEMINI_API_KEY=your_gemini_api_key
PORT=3000
```

Start the server:
```bash
npm run dev     # Development (nodemon)
npm start       # Production
```

Seed the initial quote pool:
```bash
node seedQuotes.js
```

Reset the database *(caution — wipes all data)*:
```bash
node resetDb.js
```

---

### Flutter Setup

```bash
flutter pub get
flutter run
```

> The app connects to `http://127.0.0.1:3000` by default. Update the base URL in `lib/core/network/dio_client.dart` if deploying remotely.

---

## Design System

Qelio uses an intentional, award-winning monochromatic palette with a single gold accent:

| Token | Light | Dark |
|---|---|---|
| Background | `#F9F9F9` | `#0A0A0C` |
| Surface | `#FAFAFA` | `#111116` |
| On Surface | `#0A0A0A` | `#F0F0F2` |
| Accent Gold | `#C9A84C` | `#C9A84C` |
| Border | `#E4E4E7` | `#252530` |

**Typography**: DM Sans (UI) · Playfair Display (quotes & headings)

---

## Contributors

| Name | Role |
|---|---|
| **Nikhil Madaravena** | Full Stack · Flutter & Backend |
| **Lalith Prakash** | Backend · Node.js, API & AI Service (Gemini) |

---

## License

MIT © Nikhil Madaravena
