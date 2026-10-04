# Yahpax Agent Rules

## 1. PROJECT SCOPE

Work ONLY inside:

`~/.config/quickshell/yahpax/`

Caelestia:

`~/.config/quickshell/caelestia/`

is READ-ONLY reference material.

Never modify Caelestia.

---

# 2. SINGLE ENTRY POINT

`main.qml` is the ONLY Yahpax application entry point.

Everything starts from:

`main.qml`

Do NOT create alternative root/entry files such as:

* `shell.qml`
* `App.qml`
* `Root.qml`
* another `main.qml`
* duplicate shell roots

If an existing root file performs startup responsibilities, migrate them into `main.qml`.

---

# 3. SINGLE ARCHITECTURE

Yahpax uses ONE architecture:

```text
main.qml
│
├── global/shared objects
│
├── core/
│   ├── AppState.qml
│   ├── Colors.qml
│   ├── MenuStyle.qml
│   └── services/backends
│
└── widgets/
    └── UI components
```

Never create a parallel architecture.

---

# 4. GLOBAL OBJECTS — DEFINE ONCE

Shared objects MUST be defined globally and exactly once.

Examples:

* AppState
* Colors
* MenuStyle
* shared services
* shared configuration
* shared animation system
* shared notification state
* shared connectivity state

The global object is the SINGLE SOURCE OF TRUTH.

Do NOT instantiate another copy inside a widget.

Bad:

```qml
Widget {
    MenuStyle {}
}
```

Good:

```qml
// main.qml
MenuStyle {
    id: menuStyle
}

Widget {
    menuStyle: menuStyle
}
```

---

# 5. OBJECT INJECTION

Shared objects must be injected into components.

Prefer explicit object references/properties.

Example:

```qml
Component {
    id: widget

    property var appState
    property var colors
    property var menuStyle
}
```

Then from `main.qml`:

```qml
Widget {
    appState: appState
    colors: colors
    menuStyle: menuStyle
}
```

Components must consume the injected object instead of creating their own global/shared instance.

Do not silently recreate shared services inside widgets.

---

# 6. SAME OBJECT MODEL FOR CLUSTERS

Clusters must use the SAME shared-object architecture.

A cluster is a group of related UI components, not a separate application architecture.

Example:

```text
PowerCluster
├── PowerButton
├── ShutdownButton
├── SleepButton
├── LockButton
└── SuspendButton
```

All cluster children must receive the same shared objects:

```text
AppState
Colors
MenuStyle
Services
```

Do NOT create separate instances for each child.

Example:

```qml
PowerCluster {
    appState: appState
    colors: colors
    menuStyle: menuStyle
}
```

Inside the cluster:

```qml
ShutdownButton {
    appState: root.appState
    colors: root.colors
    menuStyle: root.menuStyle
}
```

The entire cluster therefore uses the same object references.

---

# 7. CLUSTER RULE

When multiple components belong to one functional group, prefer a cluster component.

Examples:

```text
PowerCluster
NetworkCluster
BluetoothCluster
NotificationCluster
WorkspaceCluster
```

A cluster should:

* own its local layout
* coordinate its children
* receive shared global objects
* pass those objects to children
* avoid creating duplicate global state
* avoid creating duplicate styling systems

Cluster-specific state may exist when genuinely local.

Global state must remain global.

---

# 8. ONE SOURCE OF TRUTH

There must be exactly one authoritative object for each shared concern.

```text
Application state  → AppState
Colors             → Colors
Animation/style    → MenuStyle
Wi-Fi backend      → WifiService
Notification state → notification service/state
Bluetooth backend  → Bluetooth service
```

Do not create:

```text
AppState2
LocalAppState
WidgetState
CustomMenuStyle
LocalColors
```

when the existing global object already provides the required functionality.

---

# 9. CORE RESPONSIBILITIES

## AppState.qml

Global application state.

## Colors.qml

Global color/palette system.

## MenuStyle.qml

Global visual and animation rules:

* duration
* easing
* hover
* pressed
* toggle
* open
* close
* opacity
* scale
* radius
* spacing
* padding
* borders
* surfaces
* transitions

## Services

Backend/system functionality.

Widgets should consume services rather than implementing duplicate backend logic.

---

# 10. WIDGET RESPONSIBILITY

Widgets contain UI.

They may contain genuinely component-specific:

* layout
* geometry
* local state
* visual composition
* event handling

They must not recreate global:

* colors
* animation timings
* style rules
* application state
* backend services

---

# 11. STYLE AND ANIMATION

All shared visual behavior comes from:

`core/MenuStyle.qml`

Use the injected `MenuStyle` object.

Do not define duplicate:

```qml
NumberAnimation
PropertyAnimation
Behavior
duration: ...
easing.type: ...
```

when the behavior is part of the global design system.

Component-specific animation is allowed only when it is genuinely unique.

---

# 12. MAIN.QML COMPOSITION

`main.qml` should compose the entire application.

Conceptually:

```qml
ApplicationRoot {
    AppState {
        id: appState
    }

    Colors {
        id: colors
    }

    MenuStyle {
        id: menuStyle
    }

    MainBar {
        appState: appState
        colors: colors
        menuStyle: menuStyle
    }

    PowerCluster {
        appState: appState
        colors: colors
        menuStyle: menuStyle
    }

    NetworkCluster {
        appState: appState
        colors: colors
        menuStyle: menuStyle
    }
}
```

Exact QML structure may differ, but the architecture must remain equivalent.

---

# 13. BEFORE CREATING A FILE

Before creating any new QML file, ask:

1. Does an existing component already provide this?
2. Can the functionality belong in `main.qml`?
3. Can an existing `core/` object provide it?
4. Is this actually a widget?
5. Is this actually a cluster?
6. Would this create a duplicate global object?

Prefer extending the existing architecture.

---

# 14. CAELESTIA REFERENCE

Caelestia may be inspected READ-ONLY.

Use it for:

* architecture ideas
* behavior
* interaction patterns
* animation principles
* component organization

Do not blindly copy its architecture.

Adapt the useful concepts to Yahpax's single-object/injection architecture.

Never modify Caelestia.

---

# 15. CHANGE SCOPE

Only modify files required for the requested task.

Do NOT:

* redesign unrelated widgets
* rename unrelated files
* introduce duplicate systems
* modify Caelestia
* change unrelated backend behavior
* create alternative entry points
* create duplicate shared objects

---

# 16. VALIDATION

After every architectural change verify:

* `main.qml` is the only entry point.
* Global objects are instantiated once.
* Shared objects are injected.
* Clusters reuse the same object references.
* Children do not recreate global objects.
* No duplicate style system exists.
* No duplicate animation system exists.
* No duplicate backend exists.
* QML imports resolve.
* Existing functionality remains operational.

---

# 17. FINAL ARCHITECTURE RULE

Always follow:

```text
main.qml
    ↓
GLOBAL OBJECTS
    ↓
CLUSTERS
    ↓
WIDGETS
```

Shared objects are:

**defined once → injected → reused everywhere.**

Clusters use the **same object references** as the rest of Yahpax.

Never create a second architecture to solve a problem that can be solved inside the existing one.

**ONE ENTRY POINT.
ONE ARCHITECTURE.
ONE SOURCE OF TRUTH.
ONE INSTANCE OF EACH GLOBAL OBJECT.
INJECT, DON'T DUPLICATE.**

