# TODO: Add User Name to Greeting

## Backend Changes
- [x] Modify `/login` route in `backend/src/server.js` to include `name` in response

## Frontend Changes
- [x] Update login handling in `lib/main.dart` to parse and store user data (id, email, name)
- [x] Modify `FitnessHomePage` in `lib/home.dart` to accept `userName` parameter
- [x] Update `_getGreeting()` in `lib/home.dart` to take `userName` and return greeting with name
- [x] Update navigation in `lib/main.dart` to pass user name to `FitnessHomePage`
- [ ] Optionally update `HomeContent` in `lib/home.dart` similarly if needed

## Testing
- [ ] Test login and verify greeting shows user name
- [ ] Handle case if user name is null or empty
