# TODO: Add Photo and Date of Birth to User Registration

## Backend Updates
- [x] Update backend/prisma/schema.prisma: Add photo (String?) and dateOfBirth (DateTime?) to User model
- [x] Run prisma generate to update the client
- [x] Update backend/src/server.js: Modify /register route to accept and store photo and dateOfBirth

## Frontend Updates
- [x] Update lib/registration_screen.dart: Add TextField for photo URL and DatePicker for date of birth
- [x] Update _register method in registration_screen.dart to send new fields in JSON

## Testing
- [ ] Test registration with new fields to ensure backend accepts and stores them
- [ ] Verify frontend collects and sends photo and dateOfBirth correctly
