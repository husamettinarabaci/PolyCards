# PolyCards Development Guidelines

This document outlines the core development rules and guidelines for the PolyCards project. All developers and AI agents working on this project must follow these guidelines strictly.

## Language Requirements

### Code and Documentation Language
- **ALL source code MUST be written in English**
- **ALL comments MUST be written in English**
- **ALL documentation MUST be written in English**
- **ALL variable names, function names, class names MUST be in English**
- **ALL commit messages MUST be written in English**
- **ALL code reviews and discussions MUST be conducted in English**

### User-Facing Content
- User-facing content (UI text, instructions, error messages) is managed through locale files
- The application's medium of instruction is **American English**
- All explanations and teaching content presented to users are in English

## Theme and Styling Guidelines

### Material Design 3
- **ALWAYS use Material Design 3** (`useMaterial3: true`)
- The project uses a comprehensive Material 3 theme defined in `lib/config/theme.dart`
- Both light and dark themes are configured

### Typography Rules
- **DO NOT use custom CSS-style fonts**
- **DO NOT define inline font styles**
- **ALWAYS use theme typography** through `Theme.of(context).textTheme`
- Available text styles from theme:
  - `displayLarge`, `displayMedium`, `displaySmall`
  - `headlineLarge`, `headlineMedium`, `headlineSmall`
  - `titleLarge`, `titleMedium`, `titleSmall`
  - `bodyLarge`, `bodyMedium`, `bodySmall`
  - `labelLarge`, `labelMedium`, `labelSmall`

### Color Usage
- **ALWAYS use colors from the theme** through `Theme.of(context).colorScheme`
- **DO NOT hardcode color values** in widgets
- Available color scheme properties:
  - `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`
  - `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`
  - `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`
  - `error`, `onError`, `errorContainer`, `onErrorContainer`
  - `background`, `onBackground`
  - `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`
  - `outline`, `outlineVariant`

### Component Theming
- All Material 3 components (Cards, Buttons, TextFields, etc.) use theme configuration
- **DO NOT override component styles** unless absolutely necessary
- If custom styling is required, extend the theme configuration in `lib/config/theme.dart`

## Asset Management

### Images
- Word images are stored in `assets/images/words/`
- Image file naming convention: `word_XXXX.png` or `word_XXXX.jpg`
  - Example: `word_0001.png`, `word_0002.jpg`
- Word ID in locale files must match image filename
- **MUST implement fallback mechanism** for missing images
- When an image is not found, display a placeholder icon

### Locale Files
- Locale JSON files are stored in `assets/locales/`
- File naming convention: `[language_code].json`
  - Example: `en.json`, `tr.json`, `zh.json`, `ru.json`, `ar.json`, `ku.json`
- Each locale file must follow the standardized structure:
```json
{
  "language_name": "Language Name",
  "language_code": "xx",
  "words": [
    {
      "id": "word_XXXX",
      "word": "translation",
      "translation": "translation",
      "example": "example sentence",
      "category": "category"
    }
  ]
}
```

## Supported Languages

The application supports the following 6 languages:

1. **English (American)** - `en` - Primary language and medium of instruction
2. **Turkish** - `tr` - Turkey Turkish
3. **Simplified Chinese** - `zh` - 简体中文
4. **Russian** - `ru` - Русский
5. **Standard Arabic** - `ar` - العربية (Standard Arabic)
6. **Kurmanji Kurdish** - `ku` - Kurdî (Kurmanji/Northern Kurdish)

## Project Structure

```
lib/
├── config/
│   └── theme.dart          # Material Design 3 theme configuration
├── models/                 # Data models
├── services/              # Business logic and data services
├── widgets/               # Reusable widget components
├── screens/               # Screen/page widgets
└── main.dart              # Application entry point

assets/
├── locales/               # Language JSON files
│   ├── en.json
│   ├── tr.json
│   ├── zh.json
│   ├── ru.json
│   ├── ar.json
│   └── ku.json
├── images/
│   └── words/             # Word images (word_XXXX.png/jpg)
└── icons/                 # App icons
```

## Code Style Guidelines

### Dart/Flutter Best Practices
- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names in English
- Add documentation comments for public APIs
- Keep functions small and focused on a single responsibility
- Use const constructors where possible for performance

### State Management
- Use Provider for state management
- Separate business logic from UI components
- Use ChangeNotifier or similar patterns for reactive state

### Error Handling
- Always handle potential errors gracefully
- Provide meaningful error messages to users
- Log errors for debugging purposes
- Never expose technical error details to end users

### Performance
- Use const constructors for static widgets
- Implement lazy loading for images
- Optimize list rendering with proper builders
- Cache loaded locale data

## Testing Guidelines

- Write unit tests for business logic
- Write widget tests for UI components
- Test with all supported languages
- Test both light and dark themes
- Test on both iOS and Android platforms

## Version Control

### Commit Messages
- Write clear, concise commit messages in English
- Use present tense ("Add feature" not "Added feature")
- Reference issue numbers when applicable
- Follow conventional commits format when possible

### Branching
- `main` - Production-ready code
- `develop` - Development branch
- `feature/feature-name` - Feature branches
- `fix/bug-name` - Bug fix branches

## Accessibility

- Support both light and dark themes
- Ensure proper contrast ratios
- Use semantic widgets
- Provide text alternatives for images
- Support RTL languages (especially for Arabic)

## Internationalization

- All UI text must be prepared for localization
- Support RTL layouts for Arabic
- Handle different text lengths across languages
- Use proper Unicode handling for all character sets

## Performance Targets

- App startup time: < 2 seconds
- Image loading: < 500ms with caching
- Smooth animations: 60 FPS
- Memory usage: Keep under 150MB

## Security

- Never hardcode sensitive data
- Use secure storage for user preferences
- Validate all user inputs
- Keep dependencies up to date

## Documentation Requirements

- Document all public APIs
- Add inline comments for complex logic
- Keep README.md up to date
- Update this AGENTS.md when adding new guidelines

---

## Quick Reference for AI Agents

When working on this project:

1. ✅ **DO**: Write all code and comments in English
2. ✅ **DO**: Use `Theme.of(context).textTheme` for typography
3. ✅ **DO**: Use `Theme.of(context).colorScheme` for colors
4. ✅ **DO**: Implement image fallback for missing assets
5. ✅ **DO**: Follow Material Design 3 guidelines
6. ❌ **DON'T**: Use custom font styles or CSS-like styling
7. ❌ **DON'T**: Hardcode colors in widgets
8. ❌ **DON'T**: Write code or comments in languages other than English
9. ❌ **DON'T**: Override theme components without extending theme.dart

Remember: **Consistency is key. When in doubt, check the theme configuration and follow Material Design 3 patterns.**
