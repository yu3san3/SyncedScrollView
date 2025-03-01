# `SyncedScrollView`

A SwiftUI component for synchronizing scrolling across multiple views.
It allows you to create a scrollable view with fixed rows and columns, similar to a spreadsheet or table layout.

## Usage

### Simple Example:

```swift
SyncedScrollView {
    // Main scrollable content
} vSyncedContent: {
    // Vertically synchronized content
} hSyncedContent: {
    // Horizontally synchronized content
} topLeftContent: {
    // Top-left corner content (default: `EmptyView`)
}
```

For more detailed examples, see the `#Preview` of [SyncedScrollView.swift](Sources/SyncedScrollView/SyncedScrollView.swift).

## Example

An example of `SyncedScrollView` in action:

<p align="center">
    <img src="https://github.com/user-attachments/assets/9f4bf779-9747-468b-9f26-632af070d1b8" width="400"/>
</p>

## Installation

### Using [Swift Package Manager](https://swift.org/package-manager/)

In Xcode, open your project and navigate to `Project` > `Package Dependencies`.
Then, enter the following URL:

```
https://github.com/yu3san3/SyncedScrollView.git
```
