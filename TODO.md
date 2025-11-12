# TODO: Fix Flutter App Errors

## 1. Fix Drift Dependency
- [ ] Move `drift` from dev_dependencies to dependencies in pubspec.yaml

## 2. Fix NativeDatabase Import
- [ ] Ensure proper imports in lib/database/drift_database.dart

## 3. Fix Deprecated withOpacity
- [ ] Replace `withOpacity` with `withValues()` in lib/home.dart
- [ ] Replace `withOpacity` with `withValues()` in lib/main.dart

## 4. Fix BuildContext Async Gap
- [ ] Add mounted check in lib/profile_screen.dart

## 5. Fix Unnecessary Null Comparison
- [ ] Fix in lib/receipts.dart

## 6. Fix Avoid Print
- [ ] Use logging instead of print in lib/recipe_api_service.dart

## 7. Fix isBetweenValues Method
- [ ] Use `isBetween` instead in lib/services/database_service.dart

## 8. Fix Unused Variable
- [ ] Remove unused variable in lib/services/database_service.dart

## 9. Fix Value Import
- [ ] Import Value from drift in lib/services/database_service.dart

## 10. Run Commands
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze` to verify fixes
