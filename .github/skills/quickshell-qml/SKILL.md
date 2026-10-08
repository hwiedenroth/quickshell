---
name: quickshell-qml
description: "Use when creating, modifying, or reviewing Quickshell QML features. Prefer Quickshell APIs first, then compatible Qt 6.x APIs; use TapHandler and HoverHandler instead of MouseArea for ordinary tap and hover input."
---

# Quickshell QML

Build features using Quickshell's own modules and APIs wherever they fit. Use Qt Quick and other Qt 6.x APIs when Quickshell does not provide the needed capability, and keep every API compatible with the Qt version supported by the installed Quickshell runtime.

## Workflow

1. Read the relevant component and nearby QML files. Preserve their import, naming, layout, and interaction patterns.
2. Look for a suitable API in Quickshell's modules first, such as `Quickshell`, `Quickshell.Io`, `Quickshell.Wayland`, or `Quickshell.Hyprland`.
3. If no suitable Quickshell API exists, use the appropriate Qt Quick or Qt 6.x API. Check the project's runtime and the official documentation when availability or version compatibility is unclear; do not assume an API from a newer Qt release is supported.
4. Use the smallest API surface that expresses the behavior. Keep UI interactions declarative and use existing project patterns.
5. Validate changed QML with the available QML tooling or by launching Quickshell when practical.

## Pointer Input

- Use `TapHandler` for ordinary taps and clicks.
- Use `HoverHandler` for hover state and pointer-position tracking.
- Combine handlers when an element needs both tap and hover behavior; keep each handler responsible for its own interaction.
- Do not introduce `MouseArea` as the default input mechanism. Use it only when its specific behavior is required and the pointer handlers cannot express that behavior cleanly. State the reason in the implementation or review.
- Choose other Qt Quick pointer handlers, such as `DragHandler`, for their corresponding gestures rather than expanding a click handler into unrelated responsibilities.

## API and Compatibility

- Prefer Quickshell-provided functionality over implementing the same integration directly with lower-level Qt or shell calls.
- Use Qt 6.x features only when they are supported by the Qt version used to build or run this Quickshell installation.
- Import only the modules needed by the component, and verify the module and type names against Quickshell or Qt documentation when uncertain.
- Do not invent Quickshell APIs or infer support solely from a similarly named Qt API.