![](codex.png)

<div align = "center">
  <a href="https://cocoapods.org/pods/Codex">
    <img src="https://img.shields.io/cocoapods/v/codex.svg?style=flat" />
  </a>
  <a href="https://github.com/Incetro/Codex">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" />
  </a>
  <a href="https://github.com/Incetro/codex#installation">
    <img src="https://img.shields.io/badge/compatible-swift%203.0-orange.svg" />
  </a>
</div>

<div align = "center">
  <a href="https://travis-ci.org/Incetro/Codex">
    <img src="https://travis-ci.org/Incetro/codex.svg?branch=master" />
  </a>
  <a href="https://cocoapods.org/pods/Codex" target="blank">
    <img src="https://img.shields.io/cocoapods/p/codex.svg?style=flat" />
  </a>
  <a href="https://cocoapods.org/pods/Codex" target="blank">
    <img src="https://img.shields.io/cocoapods/l/codex.svg?style=flat" />
  </a>
  <br>
  <br>
</div>

**Codex** — the Swift’s `Codable` API wrapper with type inference-powered methods.

## We like codable, but...

Sometimes it's not so convenient to use `Codable` and not so elegant as it can be – we cannot set default value for certain keys, also there is no an opportunity to simplify mapping using only keys without type specifying and skip some unwanted boilerplate code.

That’s what **Codex** aims to fix.

## Examples

Here are a few examples that shows the difference between using Swift's `Codable` and the APIs that **Codex** adds to it. The main goal is to simplify serialization into one-liners and provide elegant extensions for this amazing concept.

### 🧩 Basic API

**Codex** makes a few simple changes above the standard `Codable` protocol that makes it easier to encode and decode values.

🐣 Standard `Codable`:

```swift
/// Encoding
let encoder = JSONEncoder()
let data = try encoder.encode(user)

/// Decoding
let decoder = JSONDecoder()
let user = try decoder.decode(User.self, from: data)
```

🚀 With **Codex**:

```swift
/// Encoding
let data = try user.encoded()

/// Decoding
let user = try data.decoded() as User

/// Decoding when the type can be inferred
try processUser(data.decoded())
```

### 🔑 Simplest decoding

🐣 Standard `Codable`:

```swift
struct User: Codable {

    enum CodingKeys: CodingKey {
        case name
        case surname
        case patronymic
        case social
    }

    let name: String
    let surname: String
    let patronymic: String?
    let social: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        surname = try container.decode(String.self, forKey: .surname)
        patronymic = try container.decodeIfPresent(String.self, forKey: .patronymic)
        social = (try? container.decode([String].self, forKey: .social)) ?? []
    }
}
```

🚀 With **Codex**:

```swift
struct User: Codable {
    
    let name: String
    let surname: String
    let patronymic: String?
    let social: [String]

    init(from decoder: Decoder) throws {
        name = try decoder.decode("name")
        surname = try decoder.decode("surname")
        patronymic = try decoder.decodeIfPresent("patronymic")
        social = (try? decoder.decode("social")) ?? []
    }
}
```

### 📆 Date formatting

🐣 Standard `Codable`:

```swift
struct User: Codable {

    enum CodingKeys: CodingKey {
        case name
        case surname
        case patronymic
        case social
        case birthdate
        case registrationDate
    }

    struct DateCodingError: Error {}

    static let dateFormatter = yourDateFormatter()

    let name: String
    let surname: String
    let patronymic: String?
    let social: [String]
    let birthdate: Date
    let registrationDate: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        surname = try container.decode(String.self, forKey: .surname)
        patronymic = try container.decodeIfPresent(String.self, forKey: .patronymic)
        social = (try? container.decode([String].self, forKey: .social)) ?? []
        let dateString = try container.decode(String.self, forKey: .birthdate)
        guard let birthdate = User.dateFormatter.date(from: dateString) else {
            throw DateCodingError()
        }
        self.birthdate = birthdate
        let registrationDateDouble = try container.decode(Double.self, forKey: .registrationDate)
        registrationDate = Date(timeIntervalSince1970: registrationDateDouble)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(surname, forKey: .surname)
        try container.encode(patronymic, forKey: .patronymic)
        try container.encode(social, forKey: .social)
        let dateString = User.dateFormatter.string(from: birthdate)
        try container.encode(dateString, forKey: .birthdate)
        try container.encode(registrationDate.timeIntervalSince1970, forKey: .registrationDate)

    }
}
```

🚀 With **Codex**:

```swift
struct User: Codable {

    let name: String
    let surname: String
    let patronymic: String?
    let social: [String]
    let birthdate: Date
    let registrationDate: Date

    static let dateFormatter = yourDateFormatter()

    init(from decoder: Decoder) throws {
        name = try decoder.decode("name")
        surname = try decoder.decode("surname")
        patronymic = try decoder.decodeIfPresent("patronymic")
        social = (try? decoder.decode("social")) ?? []
        birthdate = try decoder.decode("date", using: User.dateFormatter)
        registrationDate = try decoder.decode("registrationDate", transformedBy: UnixTransformer())
    }

    func encode(to encoder: Encoder) throws {
        try encoder.encode(name, for: "name")
        try encoder.encode(surname, for: "surname")
        try encoder.encode(patronymic, for: "patronymic")
        try encoder.encode(social, for: "social")
        try encoder.encode(birthdate, for: "date", using: User.dateFormatter)
        try encoder.encode(registrationDate, for: "registrationDate", transformedBy: UnixTransformer())
    }
}
```

### 🗜 Nested keys

What if we want to parse nested value? Like this:

```json
{
    "data": {
        "nested": {
            "title": "Good book"
        }
    }
}
```

🐣 Standard `Codable`:

No comments

🚀 With **Codex**:

```swift
struct Book: Decodable, Equatable {

    let title: String

    init(title: String) {
        self.title = title
    }

    init(from decoder: Decoder) throws {
        title = try decoder.decode(nestedBy: "data.nested.title")
    }
}
```

## Installation

You can use the [Swift Package Manager](https://github.com/apple/swift-package-manager) by declaring **Codex** as a dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/Incetro/codex", from: "0.1.1")
```

*For more information, see [the Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).*

You can also use [CocoaPods](https://cocoapods.org) by adding the following line to your `Podfile`:

```ruby
pod "Codex"
```

## Contributions & support

Your contributions are more than welcome.

This project does not come with GitHub Issues-based support, and users are instead encouraged to become active participants in its continued development — by fixing any bugs that they encounter, or improving the documentation wherever it’s found to be lacking.

If you wish to make a change, [open a Pull Request](https://github.com/Incetro/codex/pull/new) — even if it just contains a draft of the changes you’re planning, or a test that reproduces an issue — and we can discuss it further from there.

Hope you’ll enjoy using **Codex**!
