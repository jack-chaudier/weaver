Weaver
====

Minimal, code-editor-inspired macOS writing app for novels and short stories. Built with SwiftUI.

### Features

- Library to manage projects (create, rename, delete)
- Per-project documents/chapters (create, rename, delete)
- Clean, distraction-minimal editor with monospaced typography
- Word and character count
- Themes: Light, Dark, Solarized
- Local persistence in Application Support (sandbox-safe)

### Screenshots

TBD

### Install

- Download the latest `.zip` from Releases, unzip, and move `Weaver.app` to Applications.
- First launch may require right-click → Open due to Gatekeeper if not notarized.

### Build from source

Requirements: Xcode 16+, macOS 15+

1. Clone the repo:

```bash
git clone git@github.com:jack-chaudier/weaver.git
cd weaver
```

2. Open in Xcode and run the `weaver` scheme.

Or build via CLI:

```bash
xcodebuild -scheme weaver -configuration Release -derivedDataPath Build
```

The built app will be at `Build/Build/Products/Release/weaver.app`.

### Project structure

- `weaver/` SwiftUI app code
  - `Models/` value types and themes
  - `Views/` library, project navigator, editor, root
  - `AppModel.swift` state management and persistence
- `weaverTests/`, `weaverUITests/`

### Data storage

- Application Support: `~/Library/Application Support/<bundle id>/`
- `projects.json`: project list
- `<project-id>.documents.json`: per-project documents

### Shortcuts

- New Project: Command-N
- New Document: Shift-Command-N

### CI/CD

- Build and test on push/PR
- Create release artifacts for macOS builds on tag push `v*`
- DMG auto-update feed via Sparkle (checks GitHub Releases latest)

See `.github/workflows/`.

### License

MIT

