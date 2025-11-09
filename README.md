# FoodTracker

A Flutter app for nutrition tracking with a backend using Prisma ORM and PostgreSQL.

## Project Structure

- `lib/`: Flutter mobile app
- `backend/`: Node.js backend with Prisma ORM
- `docker-compose.yml`: Docker setup for PostgreSQL

## Backend Setup

1. Start PostgreSQL with Docker:
   ```bash
   docker-compose up -d
   ```

2. Navigate to backend directory:
   ```bash
   cd backend
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Run Prisma migrations:
   ```bash
   npm run prisma:migrate
   ```

5. Generate Prisma client:
   ```bash
   npm run prisma:generate
   ```

6. Start the backend server:
   ```bash
   npm run dev
   ```

The backend will be running on http://localhost:3000

## Flutter App Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## API Endpoints

- GET /activities - Get all activities
- POST /activities - Create a new activity
- PUT /activities/:id - Update an activity
- DELETE /activities/:id - Delete an activity

## Getting Started with Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
