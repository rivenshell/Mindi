# Mindi

> A modern SwiftUI-based iOS mindfulness application leveraging iOS 26's latest capabilities

[![iOS](https://img.shields.io/badge/iOS-26.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-26.1-blue.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Mindi combines guided breathing exercises, reflective journaling, and wellness tracking in one seamless experience, built with cutting-edge Swift 6 features and iOS 26's latest capabilities.

<img src="https://via.placeholder.com/800x400/6366f1/ffffff?text=Mindi+App+Preview" alt="Mindi App Preview" width="100%">

## Features

### 🏠 Home - Mindful Breathing Timer
- **Interactive breathing exercises** with visual guidance and calming animations
- **Customizable timer settings** for duration and breathing patterns
- **Synchronized animations** using Swift 6's animation APIs and iOS 26's `@Animatable` macro
- **Progress tracking** for daily breathing sessions
- **Liquid glass aesthetic** with ambient backgrounds
- **Enhanced haptic feedback** integration for breathing cues

### 📅 Calendar - Journaling Hub
- **Month/week view calendar** utilizing iOS 26's enhanced date pickers
- **Daily journal entry system** for gratitude and reflection
- **Visual indicators** for days with completed entries
- **Streak tracking** and consistency metrics
- **Entry history** with search and filter capabilities
- **Smart prompts** for mindful reflection
- **Smooth transitions** with SwiftUI's latest animation modifiers

### 👤 Profile - Health & Wellness Tracking
- **Personal wellness dashboard** with comprehensive statistics
- **Metrics tracking:**
  - Total meditation minutes
  - Journaling streaks
  - Breathing sessions completed
  - Mood trends over time (HealthKit integration)
- **User preferences** and customizable settings
- **Data visualization** with Swift Charts framework
- **Export functionality** for personal data
- **iOS 26 HealthKit features** with enhanced Blood Pressure tracking UI

## 🛠 Technical Stack

### Core Technologies
- **Framework:** SwiftUI (iOS 26 SDK)
- **Language:** Swift 6 with latest concurrency features
- **Platform:** iOS 26.0+
- **Development Environment:** Xcode 26.1
- **Backend:** Supabase (authentication, real-time database, RLS)

### Modern Swift Features
- ✨ **Swift Concurrency** (async/await, actors)
- 🔍 **Observation framework** (`@Observable` macro)
- 🎬 **iOS 26's `@Animatable` macro** for smooth animations
- 🏗 **Result builders** and property wrappers
- 🔒 **Swift 6 strict concurrency** checking

### iOS 26 Integration
- 🆕 **Enhanced SwiftUI components** and modifiers
- 🏥 **Improved HealthKit integration**
- 🎨 **Advanced animation APIs**
- ♿️ **Latest accessibility features**
- 📡 **NearbyInteraction capabilities** (future consideration)

### Design & UI
-  **Custom gradient themes**
-  **Liquid glass UI elements**
-  **SF Symbols 6**
-  **Studio:** cactaestudio

## 🏗 Architecture

Mindi follows a modern **MVVM architecture** with the Observation framework:

```
Mindi/
├── Models/           # Data models and business logic
├── Views/            # SwiftUI views and UI components
├── ViewModels/       # Observable view models
├── Services/         # API and backend services
├── Utilities/        # Helper functions and extensions
└── Resources/        # Assets, localizations, configurations
```

### Key Architectural Patterns
- **MVVM with Observation framework** for reactive UI updates
- **Supabase Swift SDK integration** for backend services
- **Clean separation of concerns** with modern Swift patterns
- **Type-safe API layer** using async/await
- **Main actor isolation** where appropriate

## 🚀 Installation

### Prerequisites
- **Xcode 26.1** or later
- **iOS 26.0 SDK**
- **Swift 6.0**
- **macOS Sonoma** or later

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/cactaestudio/mindi.git
   cd mindi
   ```

2. **Open in Xcode:**
   ```bash
   open Mindi.xcodeproj
   ```

3. **Install dependencies:**
   - The project uses Swift Package Manager
   - Dependencies will be resolved automatically when opening the project

4. **Configure environment:**
   - Copy `.env.example` to `.env`
   - Add your Supabase configuration (see [Environment Configuration](#environment-configuration))

5. **Build and run:**
   - Select your target device/simulator
   - Press `⌘+R` to build and run

## 🔧 Configuration

### Environment Configuration

Create a `.env` file in the project root:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Optional: Development settings
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Supabase Setup

1. **Create a new Supabase project** at [supabase.com](https://supabase.com)

2. **Database Schema:**
   ```sql
   -- Users table
   CREATE TABLE profiles (
     id UUID REFERENCES auth.users PRIMARY KEY,
     username TEXT UNIQUE,
     full_name TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Breathing sessions
   CREATE TABLE breathing_sessions (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES profiles(id),
     duration INTEGER NOT NULL,
     pattern TEXT NOT NULL,
     completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Journal entries
   CREATE TABLE journal_entries (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID REFERENCES profiles(id),
     title TEXT,
     content TEXT NOT NULL,
     mood_rating INTEGER CHECK (mood_rating >= 1 AND mood_rating <= 5),
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

3. **Row Level Security (RLS) Policies:**
   ```sql
   -- Enable RLS
   ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
   ALTER TABLE breathing_sessions ENABLE ROW LEVEL SECURITY;
   ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

   -- Policies
   CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
   CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

   CREATE POLICY "Users can view own sessions" ON breathing_sessions FOR SELECT USING (auth.uid() = user_id);
   CREATE POLICY "Users can insert own sessions" ON breathing_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "Users can view own entries" ON journal_entries FOR SELECT USING (auth.uid() = user_id);
   CREATE POLICY "Users can insert own entries" ON journal_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
   CREATE POLICY "Users can update own entries" ON journal_entries FOR UPDATE USING (auth.uid() = user_id);
   ```

## 🎯 iOS 26 Features

### Enhanced SwiftUI Components
- Utilizes iOS 26's enhanced date pickers for calendar navigation
- Implements new animation modifiers for smooth transitions
- Leverages updated navigation APIs for seamless user experience

### Advanced Animation System
```swift
// Example: Using iOS 26's @Animatable macro
@Animatable
struct BreathingAnimation: View {
    var progress: Double
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    var body: some View {
        // Smooth breathing circle animation
    }
}
```

### HealthKit Integration
- Enhanced Blood Pressure tracking UI
- Comprehensive wellness metrics
- Privacy-first health data handling

## 🔒 Swift 6 Concurrency & Safety

### Strict Data Isolation
```swift
@MainActor
class BreathingViewModel: ObservableObject {
    @Published var isActive = false
    @Published var progress: Double = 0.0
    
    func startSession() async {
        // Async breathing session logic
    }
}
```

### Modern Concurrency Patterns
- Actor-isolated data models
- Structured concurrency for API calls
- Safe cross-actor reference handling

## 🗺 Roadmap

### Version 2.0
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts integration
- [ ] Widget extensions for iOS 26
- [ ] Advanced analytics dashboard

### Version 2.1
- [ ] NearbyInteraction for group meditation sessions
- [ ] AI-powered mood insights
- [ ] Custom meditation music integration
- [ ] Accessibility improvements

### Version 3.0
- [ ] macOS companion app
- [ ] Vision Pro support
- [ ] Advanced biometric integration

## 🧪 Testing Strategy

### Unit Testing
```swift
import Testing
@testable import Mindi

@Suite("Breathing Session Tests")
struct BreathingSessionTests {
    @Test("Session duration calculation")
    func testSessionDuration() async throws {
        let session = BreathingSession(pattern: .equal, duration: 300)
        #expect(session.totalDuration == 300)
    }
}
```

### Integration Testing
- Supabase API integration tests
- HealthKit data flow validation
- SwiftUI view rendering tests

### UI Testing
- Accessibility testing
- Navigation flow validation
- Animation performance testing

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Swift Style Guide
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for code consistency
- Maintain Swift 6 strict concurrency compliance

### Contribution Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Standards
- ✅ Write comprehensive tests
- 📝 Update documentation
- 🎨 Follow design system guidelines
- ♿️ Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact & Support

### Development Team
- **Studio:** cactaestudio
- **Email:** hello@cactaestudio.com
- **Website:** [cactaestudio.com](https://cactaestudio.com)

### Support
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/cactaestudio/mindi/issues)
- 💡 **Feature Requests:** [GitHub Discussions](https://github.com/cactaestudio/mindi/discussions)
- 📧 **General Support:** support@cactaestudio.com

### Community
- 🐦 **Twitter:** [@cactaestudio](https://twitter.com/cactaestudio)
- 💬 **Discord:** [Join our community](https://discord.gg/mindi)

---

<div align="center">
  <p>Built with ☕️ using Swift 6 and iOS 26</p>
  <p><em>Mindfulness. Simplified. Modernized.</em></p>
</div>
