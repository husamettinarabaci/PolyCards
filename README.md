# PolyCards

A Flutter-based mobile application for learning the most common 1000 words across multiple languages through an English-medium instruction approach.

## Overview

PolyCards is a cross-platform (iOS & Android) language learning application that helps users master the 1000 most frequently used words in multiple languages simultaneously. The application uses English as the medium of instruction and presentation, making it ideal for English speakers who want to learn additional languages.

## Core Concept

- **English-Medium Instruction**: All explanations, UI text, and teaching content are in English
- **Multi-Language Learning**: Users can select and learn multiple target languages simultaneously
- **Common Core Vocabulary**: The same 1000 most common daily-use words across all supported languages
- **Visual Learning**: Each word is accompanied by an ideal, contextually relevant image
- **Contextual Learning**: Every word includes usage examples in sentences within its target language

## Supported Languages

The initial release includes the following target languages (all taught through English):

1. **American English** (en-US) - Also serves as the medium of instruction
2. **Turkish** (tr-TR) - Turkey Turkish
3. **Simplified Chinese** (zh-CN)
4. **Russian** (ru-RU)
5. **Standard Arabic** (ar-SA)
6. **Kurmanji Kurdish** (ku-Latn)

## Key Features

### Core Functionality (Phase 1)

1. **Language Selection**
   - On first launch, users select which languages they want to learn
   - Multiple languages can be selected simultaneously
   - Language preferences can be modified in settings

2. **Flashcard System**
   - Words are presented as cards in sequential order
   - Each card displays:
     - Word in English (the reference language)
     - Translations in all selected target languages
     - A contextually appropriate image (linked by word ID)
     - Usage example sentence in each target language
   
3. **Customizable Display**
   - Settings panel to control which languages appear on cards
   - Users can temporarily hide/show languages without removing them from their learning set
   - All modifications are persistent

4. **Visual Learning**
   - Each of the 1000 words has a unique, professionally selected image
   - Images are linked to words via word ID for consistency across languages
   - Images enhance memory retention and provide visual context

### Planned Features (Future Phases)

- **Spaced Repetition System**: Smart review scheduling based on learning progress
- **Daily Word Goals**: Set and track daily learning targets
- **Review & Reminders**: Push notifications for daily practice
- **Progress Tracking**: Visual analytics and statistics
- **Achievement System**: Gamification elements to encourage consistent learning

## Application Structure

### Data Architecture

```
/assets
  /images
    /words
      - word_0001.jpg
      - word_0002.jpg
      ...
      - word_1000.jpg
  /locales
    - en.json (American English - base language)
    - tr.json (Turkish)
    - zh.json (Simplified Chinese)
    - ru.json (Russian)
    - ar.json (Standard Arabic)
    - ku.json (Kurmanji Kurdish)
```

### Locale File Structure

Each language file contains the 1000 common words with the following structure:

```json
{
  "words": [
    {
      "id": "word_0001",
      "word": "hello",
      "translation": "[translation in target language]",
      "example": "[sentence example in target language]",
      "category": "greeting|verb|noun|adjective|preposition|time|direction|place|..."
    }
  ]
}
```

### Word Categories

Words are categorized for better organization and future filtering capabilities:

- Nouns (common objects, people, places)
- Verbs (actions, states)
- Adjectives (descriptors)
- Prepositions (spatial, temporal)
- Time-related words
- Direction words
- Greetings & common phrases
- Numbers & quantities
- And other functional categories

## Technical Stack

- **Framework**: Flutter (Dart)
- **Platforms**: iOS & Android
- **State Management**: [To be determined - Provider/Riverpod/Bloc]
- **Local Storage**: SharedPreferences for settings, Hive/SQLite for progress tracking
- **Internationalization**: Flutter's built-in i18n support with JSON locale files
- **Image Management**: Local asset management with optimized loading

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- iOS development: Xcode 14+, CocoaPods
- Android development: Android Studio, SDK 21+

### Installation

```bash
# Clone the repository
git clone [repository-url]
cd PolyCards

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### Building for Production

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

## Development Roadmap

### Phase 1: Core Foundation (Current)
- [ ] Project setup and architecture
- [ ] Prepare 1000 common words dataset for all languages
- [ ] Source and organize 1000 word images
- [ ] Create locale JSON files with words, translations, and examples
- [ ] Implement basic flashcard UI
- [ ] Implement language selection screen
- [ ] Settings panel for language display preferences
- [ ] Basic navigation and state management

### Phase 2: Enhanced Learning
- [ ] Spaced repetition algorithm
- [ ] Progress tracking system
- [ ] Daily word goals
- [ ] Review mode
- [ ] Learning statistics and analytics

### Phase 3: Engagement & Retention
- [ ] Push notifications for daily reminders
- [ ] Achievement system
- [ ] Streak tracking
- [ ] User profiles
- [ ] Dark mode support

### Phase 4: Extended Features
- [ ] Audio pronunciation for each word
- [ ] Offline mode optimization
- [ ] Export/import learning progress
- [ ] Additional language packs
- [ ] Community features

## Word Selection Criteria

The 1000 words are selected based on:

1. **Frequency**: Most commonly used in daily conversation
2. **Utility**: Practical for everyday situations
3. **Foundation**: Building blocks for language construction
4. **Universal**: Concepts that exist across all target languages

Categories include:
- Essential verbs (be, have, go, come, etc.)
- Common nouns (day, person, home, food, etc.)
- Basic adjectives (good, bad, big, small, etc.)
- Functional words (prepositions, conjunctions, pronouns)
- Numbers and time expressions
- Common phrases and greetings

## Design Principles

1. **Simplicity**: Clean, intuitive interface focused on learning
2. **Consistency**: Uniform experience across all languages
3. **Visual-First**: Images as primary learning anchors
4. **English-Medium**: All instructions and navigation in English
5. **Flexibility**: Users control their learning pace and preferences
6. **Offline-First**: Core functionality works without internet

## Contributing

[To be added when ready for contributions]

## License

[To be determined]

## Contact

[To be added]

---

**Note**: This project is currently in Phase 1 development. The core flashcard system and language foundation are being established. Future updates will add spaced repetition, progress tracking, and additional engagement features.
