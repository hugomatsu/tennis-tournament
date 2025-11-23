---
description: How to install Flutter on macOS
---

# Install Flutter on macOS

## Option 1: Using Homebrew (Recommended)
If you have Homebrew installed, this is the easiest method.

1.  **Install Flutter**:
    ```zsh
    brew install --cask flutter
    ```

2.  **Verify Installation**:
    ```zsh
    flutter doctor
    ```

## Option 2: Manual Installation

1.  **Download the SDK**:
    Go to [flutter.dev/docs/get-started/install/macos](https://flutter.dev/docs/get-started/install/macos) and download the zip file for your architecture (Apple Silicon or Intel).

2.  **Extract the file**:
    ```zsh
    cd ~/development
    unzip ~/Downloads/flutter_macos_*.zip
    ```

3.  **Add to PATH**:
    Add this line to your `~/.zshrc` file:
    ```zsh
    export PATH="$PATH:$HOME/development/flutter/bin"
    ```

4.  **Apply Changes**:
    ```zsh
    source ~/.zshrc
    ```

## Final Setup

1.  **Run Flutter Doctor**:
    Run this command to see if there are any missing dependencies (like Xcode or Android Studio):
    ```zsh
    flutter doctor
    ```

2.  **Resolve Issues**:
    Follow the output from `flutter doctor` to install any missing components.
