# TODO: Implement Profile Photo Change Feature

- [x] Add necessary imports (image_picker) to lib/profile_screen.dart
- [x] Wrap CircleAvatar with GestureDetector and add onTap handler
- [x] Implement AlertDialog in onTap to ask if user wants to change photo ("Sim" / "Não")
- [x] If "Sim", show image picker dialog for camera or gallery selection
- [x] Pick image, update _userData['photo'] with image path, save to SharedPreferences
- [x] Refresh UI with setState to display new photo
- [x] Verify camera and storage permissions in AndroidManifest.xml and Info.plist
- [x] Test the feature on a device
