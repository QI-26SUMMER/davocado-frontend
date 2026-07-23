# davocado-frontend

D-avocado — an iOS app (SwiftUI) that photographs an avocado, classifies its ripening stage
(1–5), and tells you how many days remain until your desired ripeness (D-day).

Built from the Figma design and wired up to the [`davocado-backend`](https://github.com/QI-26SUMMER/davocado-backend)
API (Spring Boot on Cloud Run).

## Screens

- **Login / Sign Up** — email + password auth
- **Scan** — take or pick an avocado photo, upload for classification
- **History** — past scans with ripeness stage, D-day, and notification status
- **Settings** — preferred ripeness stage, push notification preferences
- **Result** — ripeness stage, days until optimal, re-scan

## Requirements

- Xcode 16+, iOS 18 SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) if regenerating the
  project from `project.yml`

## Setup

```bash
xcodegen generate   # only needed if project.yml changed
open DAvocado.xcodeproj
```

## Networking

`DAvocado/Networking/` is a thin REST client for `davocado-backend`:

- Bearer-token auth (JWT, single token — no refresh), stored in the Keychain
- Every success response is unwrapped from the backend's `{ "data": ... }` envelope
- `APIConfig.baseURL` points at the deployed Cloud Run service

Known gap: the History screen's notification bell is display-only — the backend doesn't yet
expose a `PATCH /scans/{id}/notification` endpoint to toggle it.
