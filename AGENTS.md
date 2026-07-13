# AGENTS.md

## Project overview
This repository is a Flutter e-commerce app named e_mart. The main app entrypoint is [lib/main.dart](lib/main.dart), and the shared constants barrel is [lib/consts/consts.dart](lib/consts/consts.dart).

## Architecture at a glance
- UI screens live under [lib/views](lib/views) and are grouped by feature: auth, cart, category, chat, checkout, home, item detail, notification, order, profile, seller, splash, store, and wishlist.
- State and business logic live under [lib/controllers](lib/controllers). The project uses GetX controllers (`GetxController`) and the existing codebase registers them with `Get.put()` / `Get.find()`.
- Models belong under [lib/models](lib/models), while integrations and data helpers belong under [lib/services](lib/services).
- Reusable UI components that are shared across screens live under [lib/widget_common](lib/widget_common).

## Conventions to follow
- Prefer the existing GetX pattern over introducing a new state-management library. Use `Obx`, `GetBuilder`, `Get.to()`, and `Get.back()` where the current code already does so.
- Keep startup initialization order in [lib/main.dart](lib/main.dart) intact: Firebase initialization, Google Sign-In initialization, GetStorage initialization, then controller registration. Avoid changing this flow unless a feature truly requires it.
- When adding a feature, place the screen(s) in the appropriate subfolder under [lib/views](lib/views) and keep feature-specific widgets nearby when they are only used there.
- Reuse existing controllers rather than creating duplicate state holders for the same concern. If a controller already exists for a feature, extend it instead of introducing a parallel implementation.
- Use `const` constructors where possible, especially for static screens and widgets that do not need dynamic state.

## Common commands
- Install dependencies: `flutter pub get`
- Run tests: `flutter test`
- Static analysis: `flutter analyze`

## Notes and pitfalls
- Firebase-related files such as [lib/firebase_options.dart](lib/firebase_options.dart) and the platform config files are important. Do not remove or rename them carelessly.
- The app uses GetStorage for local persistence and Google Sign-In at startup. Keep initialization changes compatible with that path.
- Existing screens commonly resolve controllers with `Get.find<Controller>()` or `Get.put(Controller())`; follow that pattern for consistency with the rest of the app.
