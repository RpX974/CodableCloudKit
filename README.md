<p align="center">
<img width="200" src="https://raw.githubusercontent.com/SvenTiigi/SwiftKit/gh-pages/readMeAssets/SwiftKitLogo.png" alt="CodableCloudKit Logo">
</p>

<p align="center">
<a href="https://developer.apple.com/swift/">
<img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
</a>
<a href="http://cocoapods.org/pods/CodableCloudKit">
<img src="https://img.shields.io/cocoapods/v/CodableCloudKit.svg?style=flat" alt="Version">
</a>
<a href="http://cocoapods.org/pods/CodableCloudKit">
<img src="https://img.shields.io/cocoapods/p/CodableCloudKit.svg?style=flat" alt="Platform">
</a>
<a href="https://github.com/Carthage/Carthage">
<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
</a>
<a href="https://github.com/apple/swift-package-manager">
<img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
</a>
</p>

# CodableCloudKit

<p align="center">
CodableCloudKit allows you to easily save and retrieve Codable objects to iCloud Database (CloudKit)
</p>

## Features

- [x] ℹ️ Add CodableCloudKit features

## Example

The example application is the best way to see `CodableCloudKit` in action. Simply open the `CodableCloudKit.xcodeproj` and run the `Example` scheme.

## Installation

### CocoaPods

CodableCloudKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod 'CodableCloudKit'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate CodableCloudKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "RpX974/CodableCloudKit"
```

Run `carthage update` to build the framework and drag the built `CodableCloudKit.framework` into your Xcode project. 

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
.package(url: "https://github.com/RpX974/CodableCloudKit.git", from: "1.0.0")
]
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate CodableCloudKit into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

Before you start, you have to enable [CloudKit](https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/EnablingiCloudandConfiguringCloudKit/EnablingiCloudandConfiguringCloudKit.html) in your app.

When you did that, go to your dashboard and create all the record types you need to save.
In this example, we will use `User`.
Add a new Field to `User` with `value` as field name and `String` as field type.
All of your objects will be saved as a String.

After that, go in INDEXES, you have to add 2 indexes to your records.
The first one is `value` with `QUERYABLE` as index type.
The second one is `modifiedAt` with `SORTABLE` as index type.

Now, we should be good.

## Example

Let's say you have a `User` model you want to sync to CloudKit. This is what the model would look like:

```swift
class User: CodableCloud {
let username: String
}

//OR

class User: CodableCloud /* OR Codable & Cloud */ {
let username: String

enum CodingKeys: String, CodingKey {
case username
}

required init(username: String) {
self.username = username
super.init()
}

required override init(from decoder: Decoder) throws {
let container = try decoder.container(keyedBy: CodingKeys.self)
self.username = try container.decode(String.self, forKey: .username)
try super.init(from: decoder)
}
}
```
`CodableCloud` is a typealias of `Codable & Cloud`.

### Save

```swift
func saveInCloud(_ database: CKDatabase = CKContainer.default().privateCloudDatabase, 
_ completion: ResultCompletion<CKRecord>? = nil)
```

Save method has 2 parameters : a database with a default value (PrivateCloudDatabase) and an optional completion that returns the `CKRecord`. If the object already exists in iCloud, it will update instead of creating a new record.

```swift

// The Simplest Way
user.saveInCloud()

// With another Database. In this case, the public database

user.saveInCloud(CKContainer.default().publicCloudDatabase)

// With completion
user.saveInCloud { [weak self] (result: Result<CKRecord>) in
guard let `self` = self else { return }
switch result {
case .success(_):
print("\(user.username) saved in Cloud")
case .failure(let error):
print(error.localizedDescription)
}
}
```

### Retrieve

```swift
func retrieveFromCloud(_ database: CKDatabase = CKContainer.default().privateCloudDatabase, 
completion: @escaping ResultCompletion<[Self]>)
```

Retrieve method has 2 parameters : a database with a default value (PrivateCloudDatabase) and an optional completion that returns a `[CodableCloud]`.

```swift
User.retrieveFromCloud(completion: { [weak self] (result: Result<[User]>) in
guard let `self` = self else { return }
switch result {
case .success(let users):
print("\(users.count) users retrieved from Cloud")
case .failure(let error):
print(error.localizedDescription)
}
})
```

### Remove

```swift
func removeFromCloud(_ database: CKDatabase = CKContainer.default().privateCloudDatabase,
_ completion: ResultCompletion<CKRecord.ID?>? = nil)
```

Retrieve method has 2 parameters : a database with a default value (PrivateCloudDatabase) and an optional completion that returns the `CKRecord.ID` as optional.

```swift

// The Simplest Way
user.removeFromCloud()

// With another Database. In this case, the public database

user.removeFromCloud(CKContainer.default().publicCloudDatabase)

// With completion
user.removeFromCloud { [weak self] (result: Result<CKRecord.ID?>) in
guard let `self` = self else { return }
switch result {
case .success(_):
print("\(user.username) removed from Cloud")
case .failure(let error):
print(error.localizedDescription)
}
}
```

## Contributing
Contributions are very welcome 🙌

## License

```
CodableCloudKit
Copyright (c) 2019 CodableCloudKit laurent.grondin@epitech.eu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
