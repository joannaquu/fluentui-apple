# Fluent UI Apple
Fluent UI Apple contains native UIKit and AppKit controls aligned with [Microsoft's Fluent UI design system](https://www.microsoft.com/design/fluent/#/). 

![Build Status](https://github.com/microsoft/fluentui-apple/workflows/CI/badge.svg?branch=main)
![Localization Status](https://github.com/microsoft/fluentui-apple/workflows/Localize/badge.svg)
![CocoaPod Publishing](https://github.com/microsoft/fluentui-apple/workflows/Pod-Publish/badge.svg)
[![Build Status](https://dev.azure.com/microsoftdesign/fluentui-native/_apis/build/status/microsoft.fluentui-apple?branchName=main)](https://dev.azure.com/microsoftdesign/fluentui-native/_build/latest?definitionId=144&branchName=main)
![License](https://img.shields.io/github/license/Microsoft/fluentui-apple)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MicrosoftFluentUI)](https://cocoapods.org/pods/MicrosoftFluentUI)
![Platform](https://img.shields.io/cocoapods/p/MicrosoftFluentUI.svg?style=flat)

## Getting Started
### Install and use FluentUI

#### Requirements

- iOS 16+ or macOS 13+
- Xcode 16.3+
- Swift 5.9+

#### Using Swift Package Manager

To integrate FluentUI using SwiftUI, specify it as a dependency in your Xcode project or `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/microsoft/fluentui-apple.git", .upToNextMinor(from: "X.X.X")),
],
```

#### Using CocoaPods

To get set up with CocoaPods visit their [getting started guide](https://guides.cocoapods.org/using/getting-started.html).

To integrate FluentUI into your Xcode project using CocoaPods, specify it in your Podfile:
```ruby
pod 'MicrosoftFluentUI', '~> X.X.X'
```

### Import and use FluentUI

After the framework has been added you can import the module to use it:

For Swift
```swift
import FluentUI
```
For Objective-C
```objective-c
#import <FluentUI/FluentUI-Swift.h>
```

## List of Available Controls
For more platform-specific information, please see [the iOS readme file](Sources/FluentUI_iOS/README.md) and the [the macOS readme file](Sources/FluentUI_macOS/README.md).

## Changelog

We use [GitHub Releases](https://github.com/blog/1547-release-your-software) to manage our releases, including the changelog between every release. You'll find a complete list of additions, fixes, and changes on the [Releases page](https://github.com/microsoft/fluentui-apple/releases).

## License

All files on the FluentUI Apple GitHub repository are subject to the MIT license. Please read the [LICENSE](LICENSE) file at the root of the project.

Usage of the logos and icons referenced in FluentUI Apple is subject to the terms of the [assets license agreement](https://aka.ms/fabric-assets-license).
