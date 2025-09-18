# Interpreter Module (lib/interpreter)

Purpose
- This module contains the interpreter-facing features of the Sign Language App.
- Audience: interpreters who sign in to provide sign language services to students.

Key Capabilities
- Interpreter authentication and profile management.
- Manage availability and respond to student requests (subject to features enabled elsewhere).
- Interpreter-side UI screens, controllers, and domain logic.

How This Fits Into The App
- The app has two primary modules: Student (lib/student) and Interpreter (this folder).
- Navigation is wired centrally (see lib/infrastructure/navigation/navigation.dart), where routes for both Student and Interpreter sections are composed.

Directory Conventions
- presentation/: Flutter UI widgets/screens for interpreter flows.
- domain/: Business entities, use-cases, and interfaces specific to interpreters.
- infrastructure/: Data sources, repositories, and external integrations scoped to the interpreter domain.

Typical User Flow (Interpreter)
- Launch app and select the Interpreter section.
- Sign in or register as an interpreter.
- Update availability and/or review incoming student requests.
- Engage in sessions or communication with students (depending on enabled features and backend).

Development Notes
- Keep interpreter-specific logic inside lib/interpreter to maintain clear separation from the student module.
- Extract reusable, cross-module components into lib/infrastructure or other shared locations.
- When adding new interpreter features:
  1) Place UI under lib/interpreter/presentation.
  2) Put domain logic under lib/interpreter/domain.
  3) Place data/repository/integration code under lib/interpreter/infrastructure.
  4) Register navigation in lib/infrastructure/navigation/navigation.dart.
- Prefer small, composable widgets and thin presentation logic; move shared services or APIs to shared layers.

Testing
- For widget tests, target screens under lib/interpreter/presentation/.
- For domain or repository tests, target classes under lib/interpreter/domain and lib/interpreter/infrastructure respectively.

Notes For Maintainers
- This folder is intentionally scoped to the interpreter experience. Any student-specific logic should live under lib/student. Cross-cutting or shared functionality should reside under lib/infrastructure (e.g., navigation, theming, shared widgets/services).
