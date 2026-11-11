# Impeller Verification

- Device: Infinix X678B (`Infinix_X678B`, product `X678B-OP`; serial
  `1026825381000731`)
- OS: Android 14; build fingerprint
  `Infinix/X678B-OP/Infinix-X678B:14/UP1A.231005.007/250217V838:user/release-keys`
- Display: 1080 × 2400; active render rate 120.00001 Hz. The device reports
  60 Hz and 90 Hz as additional supported refresh rates.
- Connection: USB ADB using
  `C:\Android\Sdk\platform-tools\adb.exe`; wireless ADB setting was `0` and
  `service.adb.tcp.port` was blank.
- Command: `flutter run --profile --verbose -d 1026825381000731`
- Renderer startup evidence:

  ```text
  I/flutter (22042): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
  ```

- Impeller status: **Active (OpenGLES)**.
- Existing font setup: no bundled text typeface or `fontFamily` is configured;
  app text uses the Flutter/Android default. `assets/fonts/` contains only the
  existing Phosphor icon font assets.
