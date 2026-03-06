# Get dependencies
get:
	flutter pub get

# Clean the build
clean:
	flutter clean

# Build the app
build:
	flutter build apk

# Run the app in debug mode
run:
	flutter run

# Environment-aware runs
run-dev:
	flutter run --dart-define=ENVIRONMENT=dev

run-test:
	flutter run --dart-define=ENVIRONMENT=test

run-stage:
	flutter run --dart-define=ENVIRONMENT=stage

run-prod:
	flutter run --dart-define=ENVIRONMENT=prod

#distribute to app store
distribute:
	flutter build appbundle --release --dart-define=ENVIRONMENT=prod 

# Run all tests
test:
	flutter test

# Format code
format:
	flutter format .
