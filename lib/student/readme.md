# Student Module (lib/student)

Purpose
- This module contains the student-facing features of the Sign Language App.
- Audience: end-users who sign up as students to find and interact with interpreters.

Key Capabilities
- Student authentication and profile management (sign up/in as a student).
- Discover and view interpreters available to assist students.
- Request/engage sessions with interpreters (subject to app features enabled elsewhere).
- Student-side UI screens, controllers, and related presentation logic.

How This Fits Into The App
- The app has two primary modules: Student (this folder) and Interpreter (lib/interpreter).
- Navigation is wired centrally (see lib/infrastructure/navigation/navigation.dart), where routes for both Student and Interpreter sections are composed.

Relevant Files In This Module
- Screen: lib/student/presentation/interpreters/interpreters.screen.dart
  - UI for listing and/or exploring interpreters from the student perspective.
- Controller: lib/student/presentation/interpreters/controllers/interpreters.controller.dart
  - Handles state and logic for the interpreters list screen.

Directory Conventions
- presentation/: Flutter UI widgets/screens and view-layer state/controllers for student flows.
- Additional layers (e.g., data, domain) may be added as the app grows; keep them within lib/student to remain module-scoped.

Typical User Flow (Student)
- Launch app and choose the Student section (or land here by default if configured).
- Sign up / sign in as a student.
- Browse interpreters and view details (interpreters.screen.dart).
- Initiate a session or contact flow with an interpreter (if enabled in the app and backend).

Development Notes
- Keep student-specific logic inside lib/student to maintain clear separation from interpreter code.
- Extract reusable, cross-module components to lib/infrastructure or other shared locations as appropriate.
- When adding a new student screen:
  1) Create it under lib/student/presentation/...
  2) Add its controller/state in a colocated controllers/ directory where needed.
  3) Register navigation in lib/infrastructure/navigation/navigation.dart.
- Prefer small, composable widgets and thin controllers; move shared services or APIs to shared layers.

Testing
- For widget tests, target screens under lib/student/presentation/.
- For controller/state tests, target classes under the corresponding controllers/ folder.

Notes For Maintainers
- This folder is intentionally scoped to the student experience. Any interpreter-specific logic should live under lib/interpreter. Cross-cutting or shared functionality should reside under lib/infrastructure (e.g., navigation, theming, shared widgets/services).
