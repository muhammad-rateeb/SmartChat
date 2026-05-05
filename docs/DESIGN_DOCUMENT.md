# SmartChat — Design Document

## 1. Low-Fidelity Wireframes

### Screen 1: Splash Screen
```
┌──────────────────────────┐
│                          │
│                          │
│                          │
│      ┌──────────┐        │
│      │  LOGO    │        │
│      │SmartChat │        │
│      └──────────┘        │
│                          │
│      ───────────         │
│      Loading...          │
│                          │
│                          │
└──────────────────────────┘
```

### Screen 2: Login / Register
```
┌──────────────────────────┐
│     SmartChat             │
│                          │
│  ┌──────────────────┐    │
│  │ Email            │    │
│  └──────────────────┘    │
│  ┌──────────────────┐    │
│  │ Password         │    │
│  └──────────────────┘    │
│                          │
│  [═══ LOGIN ════════]    │
│                          │
│  --- OR ---              │
│  [G] Google Sign In      │
│                          │
│  Don't have account?     │
│  Register here           │
└──────────────────────────┘
```

### Screen 3: Home / Chat List
```
┌──────────────────────────┐
│ SmartChat    [search] [+]│
│──────────────────────────│
│ ┌──┐ AI Assistant        │
│ │AI│ Ask me anything...  │
│ └──┘              10:30a │
│──────────────────────────│
│ ┌──┐ John Doe            │
│ │JD│ Hey, how are you?   │
│ └──┘              9:15a  │
│──────────────────────────│
│ ┌──┐ Project Group       │
│ │PG│ Alice: Meeting @3pm │
│ └──┘              8:45a  │
│──────────────────────────│
│                          │
│ [Chats] [AI] [Profile]   │
└──────────────────────────┘
```

### Screen 4: Chat Screen (1:1)
```
┌──────────────────────────┐
│ <- John Doe   [call] [..]│
│──────────────────────────│
│                          │
│         ┌───────────┐    │
│         │ Hey there!│    │
│         └───────────┘    │
│  ┌───────────┐           │
│  │ Hi John!  │           │
│  └───────────┘           │
│         ┌───────────┐    │
│         │ How's it  │    │
│         │ going?    │    │
│         └───────────┘    │
│                          │
│──────────────────────────│
│ [+] [  Type message  ][>]│
└──────────────────────────┘
```

### Screen 5: AI Chat Screen
```
┌──────────────────────────┐
│ <- AI Assistant   [Clear]│
│──────────────────────────│
│                          │
│  ┌───────────┐           │
│  │ What is   │           │
│  │ Flutter?  │           │
│  └───────────┘           │
│         ┌───────────┐    │
│         │ Flutter is│    │
│         │ Google's  │    │
│         │ UI toolkit│    │
│         │ for...    │    │
│         └───────────┘    │
│                          │
│──────────────────────────│
│ [  Ask AI anything   ][>]│
└──────────────────────────┘
```

### Screen 6: Profile Screen
```
┌──────────────────────────┐
│ <- Profile               │
│──────────────────────────│
│       ┌────────┐         │
│       │ AVATAR │         │
│       └────────┘         │
│       User Name          │
│       user@email.com     │
│──────────────────────────│
│  Edit Profile            │
│  Notifications           │
│  Dark Mode      [Toggle] │
│  Privacy                 │
│  Help & Support          │
│  Logout                  │
│                          │
│ [Chats] [AI] [Profile]   │
└──────────────────────────┘
```

### Screen 7: New Chat / Search Users
```
┌──────────────────────────┐
│ <- New Chat              │
│──────────────────────────│
│ ┌──────────────────────┐ │
│ │ Search users...      │ │
│ └──────────────────────┘ │
│                          │
│  ┌──┐ Alice Smith        │
│  │AS│ alice@email.com    │
│  └──┘                    │
│  ┌──┐ Bob Johnson        │
│  │BJ│ bob@email.com      │
│  └──┘                    │
│  ┌──┐ Create Group       │
│  │++│ New group chat     │
│  └──┘                    │
│                          │
└──────────────────────────┘
```

---

## 2. Navigation Flow Diagram

```
                    [Splash Screen]
                         │
                    {Authenticated?}
                    /            \
                  No              Yes
                  │                │
            [Login Screen]    [Home Screen]
            /           \         │
     [Register]    [Google]  ─────┤
           \          /           │
            \        /      ┌─────┼──────┐
             \      /       │     │      │
          [Home Screen]  [Chats] [AI] [Profile]
                            │     │      │
                     [Chat Screen] │  [Edit Profile]
                            │     │
                     [New Chat]  [AI Chat]
                            │
                     [Group Setup]
```

---

## 3. UI Component Placement

| Screen | Component | Position | Widget Type |
|--------|-----------|----------|-------------|
| Splash | App Logo | Center | Image |
| Splash | Loading Bar | Below logo | CircularProgressIndicator |
| Login | Email Input | Upper center | TextFormField |
| Login | Password Input | Below email | TextFormField (obscured) |
| Login | Login Button | Below fields | ElevatedButton (full width) |
| Login | Google Button | Below divider | OutlinedButton with icon |
| Login | Register Link | Bottom | TextButton |
| Home | AppBar | Top fixed | AppBar (search + add icons) |
| Home | Chat Tiles | Body scroll | ListView of ListTile |
| Home | Bottom Nav | Bottom fixed | NavigationBar (3 destinations) |
| Chat | AppBar | Top fixed | AppBar (back + name + actions) |
| Chat | Messages | Body scroll | ListView.builder (reverse) |
| Chat | Bubbles | In ListView | Align + Container (L/R) |
| Chat | Input | Bottom fixed | Row (attach + field + send) |
| AI Chat | AppBar | Top fixed | AppBar (back + clear) |
| AI Chat | Messages | Body scroll | ListView.builder |
| AI Chat | Input | Bottom fixed | TextField + IconButton |
| Profile | Avatar | Top center | CircleAvatar (80dp) |
| Profile | Info | Below avatar | Column (name + email) |
| Profile | Settings | Body scroll | ListView of ListTile |

---

## 4. UX Principles Applied

| # | Principle | Application in SmartChat |
|---|-----------|------------------------|
| 1 | Visibility of System Status | Typing indicators, delivery checks, online dots, loading spinners |
| 2 | Match Real World | Chat bubble metaphor, chronological order, familiar nav pattern |
| 3 | User Control & Freedom | Swipe-to-delete, long-press options, clear history, easy logout |
| 4 | Consistency & Standards | Material 3 language, uniform spacing, predictable icons |
| 5 | Error Prevention | Form validation, confirmation dialogs, disabled empty send |
| 6 | Recognition over Recall | Avatars with initials, recent chats first, search bar |
| 7 | Flexibility & Efficiency | Pull-to-refresh, infinite scroll, keyboard dismiss |
| 8 | Aesthetic & Minimal | Clean whitespace, 2-color palette, type hierarchy, dark mode |
| 9 | Help with Errors | Inline field errors, retry snackbars, empty state messages |
| 10 | Accessibility | 48dp touch targets, WCAG AA contrast, semantic labels |

---

## 5. Design Tokens

### Color Palette
| Token | Light | Dark |
|-------|-------|------|
| Primary | #6C63FF | #6C63FF |
| Secondary | #FF6584 | #FF6584 |
| Background | #FAFAFA | #121212 |
| Surface | #FFFFFF | #1E1E1E |
| Sent Bubble | #6C63FF | #6C63FF |
| Received Bubble | #E8E8E8 | #2C2C2C |
| Text Primary | #212121 | #FAFAFA |
| Text Secondary | #757575 | #B0B0B0 |

### Typography
| Style | Font | Size | Weight |
|-------|------|------|--------|
| Headline | Poppins | 24sp | Bold |
| Title | Poppins | 20sp | SemiBold |
| Body | Poppins | 16sp | Regular |
| Caption | Poppins | 12sp | Regular |
| Button | Poppins | 14sp | Medium |

### Spacing
- Base unit: 8dp
- Screen padding: 16dp
- Card padding: 12dp
- Element gap: 8dp
- Section gap: 24dp

---

*Document Version: 1.0*  
*Last Updated: February 26, 2026*
