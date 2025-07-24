---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.

# Project Context and Guidelines for AI
File names should be in the format "<feature-name>.<file-type>.<extension>", eg. "login.controller.dart".

Project Structure:
Domain: Contains the core business logic and domain models.
- `domain/`
Infrastructure: Contains the implementation details, such as data access and external service integrations.
- `infrastructure/`
Presentation: Contains the user interface components and presentation logic.
- `presentation/`

# State Management
Use GetX for state management. Ensure that the state is reactive and follows best practices for separation of concerns.

