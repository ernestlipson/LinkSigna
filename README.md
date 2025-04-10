
# LinkSigna - Sign Language App

LinkSigna is a Flutter-based mobile application designed to bridge the gap for the hearing impaired by providing easy access to sign language interpreters and teachers. Users can sign up with OTP or social logins and book interpreters for various needs.

## Features

### User Authentication

- Sign up and login with OTP verification.
- Social login options (Google, Facebook, etc.).

### Interpreter Booking

- Search and book sign language interpreters.
- View interpreter profiles, reviews, and availability.
- Schedule and manage appointments.

### User Dashboard

- Personalized dashboard for managing bookings.
- Notifications for upcoming appointments.
- Payment integration for booking interpreters.

### Interpreter Management

- Sign language interpreters can register and create profiles.
- Manage availability and schedules.
- View booking requests and reviews.

### Accessibility Features

- User-friendly interface designed for accessibility.
- Real-time notifications and reminders.

## Screenshots

Replace the placeholders below with actual screenshots of your app.

| Feature                           | Screenshot                                    |
|-----------------------------------|----------------------------------------------|
| **Home Screen**                   | ![Home Screen](./dummy_images/home_screen.png) |
| **Interpreter Profile**           | ![Interpreter Profile](./dummy_images/profile_screen.png) |
| **Booking Screen**                | ![Booking Screen](./dummy_images/booking_screen.png) |

> Note: Add your actual images under a `dummy_images` directory in your project.

## Project Architecture

The app follows a modular and scalable clean architecture pattern:

```
LinkSigna
├── Data Layer
│   ├── Models
│   ├── Repositories
│   ├── Data Sources (API, Local DB)
├── Domain Layer
│   ├── Entities
│   ├── Use Cases
├── Presentation Layer
│   ├── Screens
│   ├── Widgets
│   ├── State Management (Provider/Bloc)
├── Core
    ├── Utilities
    ├── Constants
    ├── Dependency Injection
```
### State Management (GetX)

```markdown
## State Management with GetX

This project uses **GetX** for state management, route management, and dependency injection, making the app structure simpler and more efficient.

### Why GetX?
- **Simple to use:** No context required for state updates.
- **Efficient:** High performance with minimal boilerplate.
- **Versatile:** Combines state management, dependency injection, and routing.

### Basic Example of GetX Usage

#### State Management:
To manage the state, create a controller class that extends `GetxController`:
```dart
import 'package:get/get.dart';

class CounterController extends GetxController {
  var count = 0.obs;

  void increment() {
    count++;
  }
}
```

In your UI, use `GetBuilder` or `Obx` to update the UI reactively:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'counter_controller.dart';

class CounterPage extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GetX Counter')),
      body: Center(
        child: Obx(() => Text('Count: ${controller.count}', style: TextStyle(fontSize: 24))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### Routing:
Define your routes in `GetMaterialApp`:
```dart
GetMaterialApp(
  initialRoute: '/',
  getPages: [
    GetPage(name: '/', page: () => HomePage()),
    GetPage(name: '/details', page: () => DetailsPage()),
  ],
);
```

Navigate between pages:
```dart
Get.toNamed('/details');
```

### Get CLI

To simplify project setup and management, use **Get CLI**.

#### Installation:
Install Get CLI globally:
```bash
dart pub global activate get_cli
```

#### Common Commands:
- Create a new project:
  ```bash
  get create project
  ```
- Generate a new page:
  ```bash
  get create page:pageName
  ```
- Generate a controller:
  ```bash
  get create controller:name
  ```

For more details, visit the [GetX documentation](https://pub.dev/packages/get) and [Get CLI documentation](https://pub.dev/packages/get_cli).

---

Let me know if you'd like me to directly update this in your repository or assist further!

### Project Architecture Diagram

Include an architecture diagram that visually represents the structure above.

![Project Architecture](./dummy_images/project_architecture.png)

## Getting Started

Follow these steps to set up the project locally:

### Prerequisites
- Flutter SDK installed ([Install Flutter](https://docs.flutter.dev/get-started/install)).
- Android Studio or Visual Studio Code.

### Installation
1. Clone the repository:
   ```
   git clone https://github.com/ernestlipson/LinkSigna.git
   cd LinkSigna
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please follow the guidelines below:
- Fork the repository.
- Create a branch for your feature or fix.
- Submit a pull request for review.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

For any questions or support, please reach out to [ernestlipson](https://github.com/ernestlipson).

---

You can now replace the placeholders for the images and architecture diagram with appropriate files. Let me know if you need help creating the architecture diagram or adding more sections!
