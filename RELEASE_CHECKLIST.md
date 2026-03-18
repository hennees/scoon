# ScoonMobile Release Checklist

## 1. Build and Smoke

- Run clean build:
  - `cd ScoonMobile && xcodebuild -project ScoonMobile.xcodeproj -scheme ScoonMobile -sdk iphonesimulator -configuration Debug build CODE_SIGNING_ALLOWED=NO`
- Run preflight script:
  - `./scripts/preflight.sh`
- Verify app opens and core flows work:
  - Auth login/signup
  - Home load + filter switching
  - Favorites toggle
  - Create spot

## 2. Remote API Config

- Set runtime config in scheme env vars for local QA:
  - `SCOON_USE_REMOTE_DATA=true`
  - `SCOON_API_BASE_URL=https://your-api.example.com`
- Confirm fallback behavior:
  - Remove env vars and ensure app runs in mock mode.

## 3. Backend Contract Validation

- Confirm endpoint and payload compatibility:
  - `/auth/sign-in`, `/auth/sign-up`, `/auth/sign-out`, `/auth/me`
  - `/spots`, `/spots/favorites`, `/spots/nearby`, `/spots/{id}/favorite`
  - `/users/me`, `/users/{id}/spots/explored`, `/users/{id}/spots/saved`
  - `/creator/transactions`, `/creator/payout/pending`
- Verify DTO mapping for all fields and optional values.

## 4. Product and UX Quality

- Verify German UX copy for all error states.
- Confirm loading states and retry behavior per screen.
- Check navigation stack behavior after auth and add-spot success.

## 5. App Store/TestFlight Readiness

- Update version/build in Xcode.
- Add privacy text and metadata.
- Prepare screenshots for iPhone and iPad.
- Archive and upload to TestFlight.
- Run internal QA pass and fix blockers before external testing.
