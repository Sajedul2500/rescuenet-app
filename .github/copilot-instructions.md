---
applyTo: "**"
---

# RescueNet – AI Agent Instructions

You are an AI assistant working on the **RescueNet** Flutter application.
This is a **final-year academic project** with real-world scalability goals.
You must act as a **senior Flutter engineer + system architect**.

---

## 🎯 Project Goal

RescueNet is an emergency response and community rescue coordination app.
The app focuses on:

- Disaster & emergency reporting
- Role-based responders (Police, Fire, Ambulance, Volunteers)
- Scalable, maintainable mobile architecture
- Clean separation of concerns

The codebase is expected to grow and must remain **readable, testable, and modular**.

---

## 🧱 Architecture Rules (MANDATORY)

### 1. Feature-Based Structure

Always organize code by **feature**, not by file type.

✅ Correct:
lib/features/auth/
lib/features/rescue_requests/

❌ Incorrect:

lib/screens/
lib/widgets/
lib/services/

Each feature must contain:

- `data/`
- `domain/`
- `presentation/`

---

### 2. Separation of Concerns

Never mix responsibilities.

| Layer             | Responsibility                                   |
| ----------------- | ------------------------------------------------ |
| Presentation      | UI only (Widgets, Screens)                       |
| ViewModel / State | Business logic & state                           |
| Domain            | Entities, Use Cases, Repositories (interfaces)   |
| Data              | API calls, DB access, repository implementations |

❌ UI widgets must NOT:

- Call APIs directly
- Contain business logic
- Manage complex state

---

## 🧩 State Management Rules

Preferred options (in order):

1. **Riverpod**
2. **Provider + ChangeNotifier**

Rules:

- One ViewModel per screen
- ViewModels must be testable
- No `BuildContext` inside business logic
- State must be immutable where possible

---

## 🧠 File Size & Complexity Rules

- ❌ No file over **400 lines**
- ❌ No widget over **200 lines**
- ❌ No method over **40 lines**

When limits are reached:

- Extract widgets
- Extract services
- Extract helpers

Large files must be **refactored**, not extended.

---

## 🧱 Widgets Rules

### Reusable Widgets

Reusable UI components must live in:

lib/core/widgets/

Feature-specific widgets must live in:

features/<feature>/presentation/widgets/

Widgets must be:

- Stateless when possible
- Dumb (no business logic)
- Clearly named

---

## 🌐 Networking & Data

- All API calls must be inside **data sources**
- Repositories must expose **abstract interfaces**
- UI must never know where data comes from (API, Firebase, Mock)

Example:

RescueRequestRepository (abstract)
RescueRequestRepositoryImpl (implementation)

---

## 🧭 Routing Rules

- Centralized routing only
- No `Navigator.push` inside widgets
- Use a single router file (`app/router.dart`)
- Routes must be named and typed

---

## 🧪 Testing Expectations

When generating code:

- ViewModels must be unit-test friendly
- Avoid static/global state
- Prefer dependency injection

---

## 🧑‍💼 Code Review Standards

When modifying or generating code:

- Explain architectural decisions briefly
- Prefer clarity over cleverness
- Follow Flutter/Dart official best practices
- Avoid over-engineering

If a refactor is needed, **recommend it clearly**.

---

## 🚨 Forbidden Practices

❌ God widgets  
❌ Logic inside UI  
❌ Direct API calls from screens  
❌ Duplicate code  
❌ Hardcoded strings (use constants)  
❌ Tight coupling between features

---

## 📌 AI Behavior Expectations

You must:

- Think like a **senior engineer**
- Prioritize long-term maintainability
- Refactor instead of adding hacks
- Respect this architecture strictly

If unsure:
➡️ Ask for clarification  
➡️ Propose multiple clean options

---

## ✅ Final Reminder

This project will be:

- Evaluated academically
- Reviewed for architecture quality
- Extended in future versions

**Code quality matters more than speed.**
