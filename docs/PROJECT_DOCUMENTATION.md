# SmartChat — Project Documentation

## 1. Project Description

**SmartChat** is a real-time chat application built with Flutter that combines traditional messaging with an integrated AI assistant. Users can engage in one-on-one conversations, create group chats, and interact with an AI-powered assistant — all within a single, unified interface. The application leverages Firebase for real-time data synchronization, authentication, and cloud storage, while integrating a REST-based AI API (Google Gemini) for intelligent conversational responses.

SmartChat is designed for mobile-first experiences with support for Android, iOS, and Web platforms, following Material Design 3 guidelines and clean architecture principles.

---

## 2. Problem Statement

Modern communication apps treat messaging and AI assistance as separate tools, forcing users to switch between platforms. Students, professionals, and casual users lack a unified interface that offers:

- **Real-time person-to-person and group messaging** with delivery/read receipts
- **On-demand AI assistance** integrated directly into the chat experience
- **Secure authentication** with multiple sign-in methods
- **Offline resilience** with local caching and automatic sync
- **Cross-platform availability** from a single codebase

SmartChat addresses these gaps by providing a single application that combines human communication with AI-powered assistance, reducing context-switching and improving productivity.

---

## 3. Objectives

| # | Objective |
|---|-----------|
| O1 | Implement secure user authentication via Firebase Auth (email/password + Google Sign-In) |
| O2 | Provide real-time one-on-one and group messaging using Cloud Firestore |
| O3 | Integrate an AI assistant (Google Gemini API) for in-app conversational help |
| O4 | Support media sharing (images) via Firebase Cloud Storage |
| O5 | Deliver push notifications for new messages using Firebase Cloud Messaging |
| O6 | Implement online/offline status tracking and typing indicators |
| O7 | Provide dark mode and theme customization |
| O8 | Ensure clean architecture with Riverpod state management |
| O9 | Achieve responsive UI across mobile and web platforms |
| O10 | Maintain production-level code quality with null safety and documentation |

---

## 4. Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | User can register with email/password | High |
| FR-02 | User can login with email/password | High |
| FR-03 | User can login with Google Sign-In | High |
| FR-04 | User can view a list of all conversations | High |
| FR-05 | User can start a new one-on-one chat | High |
| FR-06 | User can send and receive text messages in real-time | High |
| FR-07 | User can interact with AI assistant | High |
| FR-08 | User can view online/offline status of contacts | Medium |
| FR-09 | User can see typing indicators | Medium |
| FR-10 | User can send image messages | Medium |
| FR-11 | User can create group chats | Medium |
| FR-12 | User can edit their profile (name, avatar) | Medium |
| FR-13 | User can search for other users | Medium |
| FR-14 | User can receive push notifications | Medium |
| FR-15 | User can toggle dark mode | Low |
| FR-16 | User can delete messages | Low |
| FR-17 | User can clear AI chat history | Low |
| FR-18 | User can logout | High |

---

## 5. Non-Functional Requirements

| ID | Requirement | Metric |
|----|-------------|--------|
| NFR-01 | **Performance**: Messages delivered in < 500ms on stable connection | Latency |
| NFR-02 | **Scalability**: Support 10,000+ concurrent users via Firebase | Capacity |
| NFR-03 | **Availability**: 99.9% uptime (Firebase SLA) | Uptime |
| NFR-04 | **Security**: All data encrypted in transit (TLS) and at rest | Encryption |
| NFR-05 | **Security**: Firebase Security Rules enforce per-user access control | Authorization |
| NFR-06 | **Usability**: App usable with < 5 minutes of onboarding | Learnability |
| NFR-07 | **Compatibility**: Android 6.0+, iOS 12+, Modern browsers | Platform |
| NFR-08 | **Reliability**: Offline messages queued and sent on reconnection | Resilience |
| NFR-09 | **Maintainability**: Clean architecture with < 300 LOC per file | Code Quality |
| NFR-10 | **Accessibility**: WCAG AA color contrast, 48dp minimum touch targets | Accessibility |

---

## 6. Use Case Diagram

```
                        ┌─────────────────────────────────────┐
                        │           SmartChat System           │
                        │                                     │
    ┌──────┐            │  ┌─────────────────────────┐        │
    │      │───────────►│  │  Register Account        │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Login (Email/Google)     │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  View Chat List           │        │
    │ USER │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Send/Receive Messages    │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │        ┌──────────┐
    │      │            │  │  Chat with AI Assistant   │───────│───────►│ AI API   │
    │      │            │  └─────────────────────────┘        │        │ (Gemini) │
    │      │            │                                     │        └──────────┘
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Create Group Chat        │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │        ┌──────────┐
    │      │            │  │  Send Image Messages      │───────│───────►│ Firebase │
    │      │            │  └─────────────────────────┘        │        │ Storage  │
    │      │            │                                     │        └──────────┘
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Search Users             │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Edit Profile             │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Toggle Dark Mode         │        │
    │      │            │  └─────────────────────────┘        │
    │      │            │                                     │
    │      │───────────►│  ┌─────────────────────────┐        │
    │      │            │  │  Logout                   │        │
    └──────┘            │  └─────────────────────────┘        │
                        │                                     │
                        └─────────────────────────────────────┘
                                         │
                                         ▼
                                  ┌──────────────┐
                                  │   Firebase    │
                                  │  (Auth, DB,   │
                                  │   FCM, Store) │
                                  └──────────────┘
```

---

## 7. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │  Screens  │ │ Widgets  │ │  Themes  │ │  Routes  │          │
│  └─────┬────┘ └─────┬────┘ └──────────┘ └──────────┘          │
│        │             │                                          │
│        ▼             ▼                                          │
│  ┌─────────────────────────────────┐                           │
│  │    Riverpod Providers           │                           │
│  │  (State Management Layer)       │                           │
│  └─────────────┬───────────────────┘                           │
└────────────────┼────────────────────────────────────────────────┘
                 │
┌────────────────┼────────────────────────────────────────────────┐
│                ▼      DOMAIN / SERVICE LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  Auth Service │  │ Chat Service │  │  AI Service  │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ User Service  │  │ Storage Svc  │  │Notification  │         │
│  └──────┬───────┘  └──────┬───────┘  │  Service     │         │
│         │                  │          └──────┬───────┘         │
└─────────┼──────────────────┼─────────────────┼──────────────────┘
          │                  │                  │
┌─────────┼──────────────────┼─────────────────┼──────────────────┐
│         ▼                  ▼                  ▼                  │
│                      DATA LAYER                                 │
│  ┌────────────────────────────────────────────────┐            │
│  │              Firebase SDK                       │            │
│  │  ┌─────────┐ ┌───────────┐ ┌────────────────┐ │            │
│  │  │  Auth   │ │ Firestore │ │ Cloud Storage  │ │            │
│  │  └─────────┘ └───────────┘ └────────────────┘ │            │
│  │  ┌──────────────────────┐                      │            │
│  │  │  Cloud Messaging     │                      │            │
│  │  └──────────────────────┘                      │            │
│  └────────────────────────────────────────────────┘            │
│                                                                 │
│  ┌────────────────────────────────────────────────┐            │
│  │          External REST API                      │            │
│  │  ┌──────────────────────────────┐              │            │
│  │  │  Google Gemini AI API        │              │            │
│  │  └──────────────────────────────┘              │            │
│  └────────────────────────────────────────────────┘            │
│                                                                 │
│  ┌────────────────────────────────────────────────┐            │
│  │          Models (Data Classes)                  │            │
│  │  ┌────────┐ ┌─────────┐ ┌──────────┐          │            │
│  │  │ User   │ │ Message │ │ ChatRoom │          │            │
│  │  └────────┘ └─────────┘ └──────────┘          │            │
│  └────────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Database Schema (Cloud Firestore)

### Collection: `users`
```
users/{userId}
├── uid: string (Firebase Auth UID)
├── email: string
├── displayName: string
├── photoURL: string (nullable)
├── isOnline: boolean
├── lastSeen: timestamp
├── createdAt: timestamp
├── fcmToken: string (nullable)
└── bio: string (default: "")
```

### Collection: `chatRooms`
```
chatRooms/{chatRoomId}
├── id: string
├── type: string ("oneToOne" | "group" | "ai")
├── participants: array<string> (list of userIds)
├── participantNames: map<string, string> (userId → displayName)
├── lastMessage: string
├── lastMessageTime: timestamp
├── lastMessageSenderId: string
├── groupName: string (nullable, for groups)
├── groupPhoto: string (nullable, for groups)
├── createdBy: string (userId)
├── createdAt: timestamp
└── unreadCount: map<string, number> (userId → count)
```

### Sub-collection: `chatRooms/{chatRoomId}/messages`
```
messages/{messageId}
├── id: string
├── senderId: string (userId)
├── senderName: string
├── text: string
├── imageURL: string (nullable)
├── type: string ("text" | "image" | "ai_response")
├── timestamp: timestamp
├── readBy: array<string> (list of userIds)
└── isDeleted: boolean (default: false)
```

### Collection: `aiChats`
```
aiChats/{userId}/messages/{messageId}
├── id: string
├── role: string ("user" | "assistant")
├── content: string
├── timestamp: timestamp
└── isError: boolean (default: false)
```

### Firestore Security Rules Summary
```
- users/{userId}: read by any authenticated user; write only by owner
- chatRooms/{chatRoomId}: read/write only by participants
- chatRooms/{chatRoomId}/messages: read/write only by room participants
- aiChats/{userId}: read/write only by owner
```

### Entity Relationship Diagram
```
┌──────────────┐       ┌───────────────────┐       ┌──────────────┐
│    User      │       │    ChatRoom       │       │   Message    │
├──────────────┤       ├───────────────────┤       ├──────────────┤
│ uid (PK)     │◄─────►│ participants[]    │       │ id (PK)      │
│ email        │       │ id (PK)           │◄──────│ chatRoomId   │
│ displayName  │       │ type              │       │ senderId(FK) │
│ photoURL     │       │ lastMessage       │       │ text         │
│ isOnline     │       │ lastMessageTime   │       │ imageURL     │
│ lastSeen     │       │ groupName         │       │ type         │
│ fcmToken     │       │ createdBy (FK)    │       │ timestamp    │
│ createdAt    │       │ createdAt         │       │ readBy[]     │
│ bio          │       │ unreadCount{}     │       │ isDeleted    │
└──────────────┘       └───────────────────┘       └──────────────┘
       │                                                   │
       │              ┌───────────────────┐                │
       └─────────────►│   AI Chat Message │◄───────────────┘
                      ├───────────────────┤
                      │ id (PK)           │
                      │ userId (FK)       │
                      │ role              │
                      │ content           │
                      │ timestamp         │
                      │ isError           │
                      └───────────────────┘
```

---

## 9. Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Management | Riverpod | ^2.5.0 |
| Authentication | Firebase Auth | latest |
| Database | Cloud Firestore | latest |
| File Storage | Firebase Cloud Storage | latest |
| Push Notifications | Firebase Cloud Messaging | latest |
| AI Integration | Google Gemini REST API | v1 |
| HTTP Client | http package | ^1.2.0 |
| Image Picker | image_picker | ^1.0.0 |
| Local Storage | shared_preferences | ^2.2.0 |
| Routing | GoRouter | ^14.0.0 |

---

## 10. Folder Structure (Clean Architecture)

```
lib/
├── main.dart                    # App entry point
├── app/
│   ├── app.dart                 # MaterialApp widget
│   ├── routes.dart              # GoRouter configuration
│   └── theme.dart               # Light & dark theme data
├── core/
│   ├── constants.dart           # App-wide constants
│   ├── utils.dart               # Helper functions
│   └── extensions.dart          # Dart extension methods
├── models/
│   ├── user_model.dart          # User data class
│   ├── chat_room_model.dart     # ChatRoom data class
│   ├── message_model.dart       # Message data class
│   └── ai_message_model.dart    # AI message data class
├── services/
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── chat_service.dart        # Firestore chat operations
│   ├── ai_service.dart          # Gemini API integration
│   ├── storage_service.dart     # Firebase Storage operations
│   ├── user_service.dart        # User CRUD operations
│   └── notification_service.dart# FCM push notifications
├── providers/
│   ├── auth_provider.dart       # Auth state providers
│   ├── chat_provider.dart       # Chat state providers
│   ├── ai_provider.dart         # AI chat providers
│   ├── user_provider.dart       # User data providers
│   └── theme_provider.dart      # Theme mode provider
├── screens/
│   ├── splash_screen.dart       # Splash/loading screen
│   ├── auth/
│   │   ├── login_screen.dart    # Login screen
│   │   └── register_screen.dart # Registration screen
│   ├── home/
│   │   └── home_screen.dart     # Main tabbed screen
│   ├── chat/
│   │   ├── chat_list_screen.dart# List of conversations
│   │   ├── chat_screen.dart     # Individual chat view
│   │   └── new_chat_screen.dart # Start new conversation
│   ├── ai/
│   │   └── ai_chat_screen.dart  # AI assistant screen
│   └── profile/
│       ├── profile_screen.dart  # User profile
│       └── edit_profile_screen.dart # Edit profile
└── widgets/
    ├── chat_tile.dart           # Chat list item
    ├── message_bubble.dart      # Message bubble widget
    ├── ai_message_bubble.dart   # AI message bubble
    ├── user_avatar.dart         # Circular avatar widget
    ├── loading_widget.dart      # Reusable loader
    └── empty_state.dart         # Empty state placeholder
```

---

*Document Version: 1.0*  
*Last Updated: February 26, 2026*  
*Author: SmartChat Development Team*
