# AM5 Royal Customer App

Flutter customer application for AM5 Royal, migrated from the LIVORA customer app and integrated with the AM5 backend at `https://api.am5royal.com/api/v1`.

## Structure

```
am5customer/
├── lib/                    # Customer app source (40 screens, 5-tab shell)
├── packages/
│   ├── am5_api/            # API client + AM5 adapters
│   ├── am5_core/           # Shared models
│   └── am5_ui/             # Design system
└── pubspec.yaml
```

## Authentication

OTP-only (phone or email):

- `POST /auth/customer/send-otp`
- `POST /auth/customer/verify-otp`
- `GET /auth/customer/me`

## Run

```bash
cd am5customer
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.am5royal.com/api/v1
```

For local backend:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

## Migration status — complete

All LIVORA customer app screens are present under `lib/features/`:

| Feature | Status |
|---------|--------|
| OTP auth (welcome, login, OTP) | ✅ AM5 backend |
| Home, catalog, search, AI assistant | ✅ Catalog + client search |
| Bookings (list, create, cancel, pay) | ✅ AM5 orders (COD) |
| Professionals / vendors | ✅ `/catalog/vendors` |
| Addresses + map pin picker | ✅ `/location/addresses` |
| Profile + edit profile | ✅ `/auth/customer/me` |
| Settings (theme, locale) | ✅ Local preferences |
| Shop (packages, cart, orders) | ✅ `/catalog/packages` + local cart |
| Wallet + payments | ✅ COD stub |
| Support tickets | ✅ `/engagement/ticket(s)` |
| Invoices | ✅ Mapped from `/orders/` |
| Referral | ✅ Customer code from profile |
| Membership | ✅ Empty plans (coming soon UI) |
| Notifications | ✅ Empty list (push via FCM token) |
| Chat | ✅ Coming-soon thread (no backend) |
| Live tracking | ✅ Unavailable state (no backend) |

### Not in AM5 backend (graceful degradation)

- In-app chat & voice calls
- Live GPS tracking
- Customer wallet & online payments
- Membership plans & subscriptions
- Professional reviews
- Password / email verification flows (removed from routes)

### Backend routes wired for customer app

- `/engagement/*` — support tickets
- `/images/themeImages` — home banners

## Password auth screens

`register_page`, `forgot_password_page`, `reset_password_page`, `verify_email_page`, and `change_password_page` exist in the codebase but are **not routed** — AM5 uses OTP-only auth.
