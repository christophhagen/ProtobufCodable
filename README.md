# ProtobufCodable

This framework provides encoding and decoding of Swift `Codable` types, which is compatible with the [Google Protocol Buffer](https://developers.google.com/protocol-buffers) format.

**Note** `ProtobufCodable` only supports a subset of `Codable`, due to the limitations of Protocol Buffers. 
If you're looking for a binary encoder with full support of all `Codable` features, have a look at `BinaryCodable`.

## Why?

Considering that Apple itself provides an implementation to use [Google Protocol Buffers in Swift](https://github.com/apple/swift-protobuf), why is there a need to provide another library for binary encoding/decoding with the same format?

The biggest advantage is that there is less work to do.
With [swift-protobuf](https://github.com/apple/swift-protobuf), you have to write (and understand) a `.proto` file, and install the `protoc` compiler with the Swift plugin.
Then you have to generate the file, and integrate it into your code.

Using `ProtobufCodable` makes this much faster.
Conform your type to `Codable` (while respecting the [limitations](#supported-protobuf-types), and happily encode and decode `Protobuf`-compatible representations.

#### Ensuring consistency

Encoding formats for data exchange are meant to be stable, since sender and receiver may be using different platforms, programming languages, or software versions.
The Protobuf format is very aware of this fact, and the [documentation](https://protobuf.dev/programming-guides/dos-donts/) provides very useful pointers to minimize errors across versions.
You should be very careful when changing any `Codable` types used with `ProtobufCodable` to ensure that there are no decoding problems for older versions or stored data.

### Why not?

There are instances when [swift-protobuf](https://github.com/apple/swift-protobuf) is the better choice:
* **Speed**: As of now, `swift-protobuf` is about 30% faster for small messages than `ProtobufCodable`. Consider this if speed is an absolute priority.
* **Consistency**: If you're already using `.proto` files within a project, it may be best to generate Swift code for them in order to guarantee consistency of the definitions.

# Installation

## Swift Package Manager

Simply include in your `Package.swift`:
```swift
dependencies: [
    .package(
        name: "ProtobufCodable", 
        url: "https://github.com/christophhagen/ProtobufCodable", 
        from: "1.0.0")
],
targets: [
    .target(name: "MyTarget", dependencies: ["ProtobufCodable"])
]
```

## Xcode project

Select your `Project`, navigate to the `Package Dependencies` tab, and add `https://github.com/christophhagen/ProtobufCodable` using the `+` button.

# Usage

While `ProtobufCodable` works with `Codable`, but not all features are supported, due to the `Protobuf` format being more limited.
What follows is a description of all available `Protobuf` features, and how they are implemented in Swift.

### Messages

Protobuf `message`s are simply translated as Swift `struct`s of `class`es.

The proto definition

```proto
message MyType {
    int64 value = 1;
}
```

would be equivalent to

```swift
struct MyType: Codable {
    let value: Int64
    
    enum CodingKeys: Int, CodingKey {
        case value = 1
    }
}
```

The first thing to note is the addition of the `CodingKeys` enum, which is how `Codable` specifies [integer keys](https://developer.apple.com/documentation/swift/codingkey) for properties.
The same [restrictions](https://protobuf.dev/programming-guides/proto3/#assigning) as with Protobuf field numbers apply:
- The field number must be between `1` and `536,870,911`
- The given number must be unique among all fields for that message.
- Field numbers `19,000` to `19,999` are reserved for the Protocol Buffers implementation.

### Supported Protobuf types

The type of the property must match one of the following:

| Proto type | Swift type | Comment
| :--- | :--- | :--- |
| bool | Bool |
| string | String |
| bytes | Data |
| double | Double | 64-bit
| float | Float | 32-bit
| int32 | Int32 | Preferred for positive values
| int64 | Int64, Int | Preferred for positive values
| uint32 | UInt32 |
| uint64 | UInt64 |
| sint32 | [Signed\<Int32\>](#signed-wrapper) | For positive and negative numbers
| sint64 | [Signed\<Int64\>, Signed\<Int\>](#signed-wrapper) | For positive and negative numbers
| fixed32 | [Fixed\<UInt32\>](#fixed-wrapper) | Always 4 byte
| fixed64 | [Fixed\<UInt64\>, Fixed\<UInt\>](#fixed-wrapper) | Always 8 byte
| sfixed32 | [Fixed\<Int32\>](#fixed-wrapper) | Always 4 byte
| sfixed64 | [Fixed\<Int64\>, Fixed\<Int\>](#fixed-wrapper) | Always 8 byte
| repeated | [Array](#arrays) |
| oneof | [OneOf](#oneof) |
| map | [Dictionary](#dictionary) |
| enum | [Enum](#enum) | With integer raw values
| any | - | Not supported

### Signed wrapper

The `@Signed` property wrapper can be applied to properties to switch them from representing `int32` or `int64` protobuf types to `sint32` and `sint64`.
These types are more efficient when encoding negative numbers.

```swift
struct MyType: Codable {

    // Equivalent to `sint64`
    @Signed
    let value: Int64
    
    enum CodingKeys: Int, CodingKey {
        case value = 1
    }
}
```

### Fixed wrapper

Similarly to `@Signed`, the `@Fixed` property wrapper converts integers to fixed-size format:

```swift
struct MyType: Codable {

    // Equivalent to `sfixed64`
    @Fixed
    let value: Int64
    
    enum CodingKeys: Int, CodingKey {
        case value = 1
    }
}
```

The wrapper converts the following types:

| Swift type | Standard proto type | Fixed proto type
| :--- | :--- | :--- |
| UInt32 | uint32 | fixed32
| UInt64, UInt | uint64 | fixed64
| Int32 | int32 | sfixed32
| Int64, Int | int64 | sfixed64

### Arrays

Protobuf `repeated` fields are equivalent to Swift `Array`s, although other types of sequences may also be used (like `Set`).

<details>

<summary>Protobuf and Swift definitions</summary>

#### Protobuf

```proto
message MyMessage {

    repeated int32 values = 1;
}
```

#### Swift

```swift
struct MyMessage {

    var values: [Int32]

    enum CodingKeys: Int, CodingKey {
        case values = 1
    }
}
```

</details>

#### Packed arrays

Protobuf 3 and `ProtobufCodable` use the [packed](https://protobuf.dev/programming-guides/encoding/#packed) format for repeated fields of primitive types (any [scalar type](https://protobuf.dev/programming-guides/proto2/#scalar) that is not `String` or `Data`).

To use unpacked repeated fields, use the `@PackedFalse` wrapper on an array, which is equivalent to the `[packed = false]` protobuf option.

<details>

<summary>Protobuf and Swift definitions</summary>

#### Protobuf

```proto
message MyMessage {

    repeated int32 values = 1 [packed=false];
}
```

#### Swift

```swift
struct MyMessage {

    @PackedFalse
    var values: [Int32]

    enum CodingKeys: Int, CodingKey {
        case values = 1
    }
}
```

</details>

### OneOf

The Protobuf [oneof](https://protobuf.dev/programming-guides/proto3/#oneof) type has no basic equivalent in Swift.
The desired behaviour can be reproduced by conforming an enum with associated values to the `OneOf` protocol.

```proto
message SampleMessage {
    oneof selection {
        string name = 4;
        SubMessage sub_message = 9;
    }
}
```

This is equivalent to:

```swift
struct SampleMessage {

    var oneof: Selection

    enum Selection: OneOf {
        case name(String)
        case subMessage(SubMessage)

        enum CodingKeys: Int, CodingKey {
            case name = 4
            case subMessage = 9
        }
    }

    enum CodingKeys: Int, CodingKey {
        case oneof = 123 // Irrelevant, not used
    }
}
```

Note that the `OneOf` protocol has no additional requirements, it is only used as an indicator to treat the type as a `OneOf`.
If the enum doesn't match the correct format, then an encoding error will be thrown.

### Dictionary

[Protobuf maps](https://protobuf.dev/programming-guides/proto3/#maps) are handled by Swift `Dictionary` types.
For a dictionary to be suitable, the `Key` has to be an integer, `Bool` , or `String`.
The `Value` can be any valid protobuf type, except another dictionary.

<details>

<summary>Protobuf and Swift definitions</summary>

#### Protobuf

```proto
message MyMessage {

    map<string, Project> projects = 3;
}
```

#### Swift

```swift
struct MyMessage {

    var projects: [String: Project]

    enum CodingKeys: Int, CodingKey {
        case projects = 3
    }
}
```

</details>

### Enum

[Protobuf enums](https://protobuf.dev/programming-guides/proto3/#enum) are represented as Swift enums with `RawValue` of type `Int`, `Int64`, or `Int32`.
According to the protobuf spec, each enum must have a default case with `rawValue = 0`.
According to the protobuf spec, enumerator constants must be in the range of a 32-bit integer.

<details>

<summary>Protobuf and Swift definitions</summary>

#### Protobuf

```proto
enum Corpus {
    CORPUS_UNSPECIFIED = 0;
    CORPUS_UNIVERSAL = 1;
    CORPUS_WEB = 2;
    CORPUS_IMAGES = 3;
    CORPUS_LOCAL = 4;
    CORPUS_NEWS = 5;
    CORPUS_PRODUCTS = 6;
    CORPUS_VIDEO = 7;
}

message SearchRequest {
    string query = 1;
    int32 page_number = 2;
    int32 results_per_page = 3;
    Corpus corpus = 4;
}
```

#### Swift

```swift

enum Corpus: Int, Codable {
    case unspecified = 0
    case universal = 1
    case web = 2
    case images = 3
    case local = 4
    case news = 5
    case products = 6
    case video = 7
}

struct MyMessage {
    var query: String
    var pageNumber: Int32
    var resultsPerPage: Int32
    var corpus: Corpus

    enum CodingKeys: Int, CodingKey {
        case query = 1
        case pageNumber = 2
        case resultsPerPage = 3
        case corpus = 4
    }
}
```

</details>

## Converting from/to data

Simply import the module when you need to encode or decode a message:

```swift
import ProtobufCodable
```

### Encoding

Construct an encoder when converting instances to binary data, and feed the message(s) into it:

```swift
let message = Message(...)

let encoder = ProtobufEncoder()
let data = try encoder.encode(message)
```

It's also possible to encode single values, arrays, optionals, sets, enums, and dictionaries, so long as they conform to `Codable`.

### Decoding

Decoding instances from binary data works much the same way:

```swift
let decoder = ProtobufDecoder()
let message = decoder.decode(Message.self, from: data)
```

Alternatively, the type can be inferred:

```swift
let message: Message = decoder.decode(from: data)
```

### Sorting keys

The `ProtobufEncoder` provides the `sortKeysDuringEncoding` option, which forces fields in "keyed" containers, such as `struct` properties (and some dictionaries), to be sorted in the binary data. 
This sorting is done by using either the [integer keys](#coding-keys) (if defined), or the property names.

Sorting the binary data does not influence decoding, but introduces a computation penalty during encoding. 
It should therefore only be used if the binary data must be consistent across multiple invocations.

**Note:** The `sortKeysDuringEncoding` option does **not** guarantee deterministic binary data, and should be used with care.
Elements of any non-ordered types (Sets, Dictionaries) will appear in random order in the binary data.
Please also see the [Protobuf information](https://protobuf.dev/programming-guides/serialization-not-canonical/) on this topic.

### Merging

Protocol Buffers support the [merging of messages](https://developers.google.com/protocol-buffers/docs/encoding#optional), which overwrites non-repeated fields, and concatenates repeated fields.

`ProtobufCodable` also supports this feature in most cases.
Just encode the messages, and decode the joined data.

### Errors

It is possible for both encoding and decoding to fail. 

All possible errors occuring during encoding produce `EncodingError` errors, while unsuccessful decoding produces `DecodingError`s. See the documentation of the types to learn more about the different error conditions.

## Roadmap

### Generate protobuf definitions

It should be possible to generate a string containing a working Protobuf definition for any type that is determined to be Protobuf compatible.
This may be possible using `Mirror`, or by encoding one or more instances to figure out the structure.

### Speed

Increasing the speed of the encoding and decoding process is not a huge priority at the moment. `ProtobufCodable` is about 30% slower than `swift-protobuf`, but still fast enough for most cases (`0.03ms` for encoding of a small object on a MacBook Air M1). If you have any pointers on how to improve the performance further, feel free to contribute.

## Contributing

Users of the library are encouraged to contribute to this repository.

### Feature suggestions

Please file an issue with a description of the feature you're missing. Check other open and closed issues for similar suggestions and comment on them before creating a new issue.

### Bug reporting

File an issue with a clear description of the problem. Please include message definitions and other data where possible so that the error can be reproduced.

### Documentation

If you would like to help translate the documentation of this library into other languages, please also open an issue, and I'll contact you for further discussions.
