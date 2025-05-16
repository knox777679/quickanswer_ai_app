
# QuickAnswer AI App

This Flutter app allows university students to upload a question screenshot, extract text using ML Kit OCR, and get AI-generated answers from OpenAI's GPT model.

## Features

- Image picker to select question screenshots
- Text recognition (OCR) using Google ML Kit
- Query OpenAI GPT-3.5-turbo for answers
- Dark Mode toggle
- Clean, modern UI with cards and Google Fonts

## Getting Started

### Prerequisites

- Flutter SDK installed: https://flutter.dev/docs/get-started/install
- An OpenAI API key (replace `YOUR_OPENAI_API_KEY_HERE` in `lib/main.dart`)

### Setup

1. Clone this repository or unzip the project folder.
2. Run `flutter pub get` to install dependencies.
3. Replace `YOUR_OPENAI_API_KEY_HERE` in `lib/main.dart` with your OpenAI API key.
4. Run the app on an emulator or physical device:
   ```
   flutter run
   ```

## Dependencies

- [image_picker](https://pub.dev/packages/image_picker)
- [google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition)
- [http](https://pub.dev/packages/http)
- [google_fonts](https://pub.dev/packages/google_fonts)

## Notes

- Ensure your device/emulator has internet access to call OpenAI API.
- You can switch between Light and Dark mode using the toggle in the app bar.

## License

MIT License
