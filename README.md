# ProtobufCodable

A binary encoder for Swift `Codable` types. Convert objects to binary data, which can be compliant with the [Google Protocol Buffer](https://developers.google.com/protocol-buffers) format for compatible data types. It can also encode additional types unsupported by Protobuf, such as optionals, single values, arrays, and dictionaries.

# Installation

## Swift Package Manager

Simply include in your `Package.swift`:
```swift
dependencies: [
    .package(name: "ProtobufCodable", url: "https://github.com/christophhagen/ProtobufCodable", from: "0.1.0")
],
targets: [
    .target(name: "MyTarget", dependencies: ["ProtobufCodable"])
]
```

## Xcode project

Select your `Project`, navigate to the `Package Dependencies` tab, and add `https://github.com/christophhagen/ProtobufCodable` using the `+` button.

# Usage

Let's assume a message definition: 

```swift
struct Message: Codable {

    var sender: String
    
    var isRead: Bool
    
    var unreadCount: Int
}
```

Simply import the module when you need to encode or decode a message:

```swift
import ProtobufCodable
```

## Encoding

Construct an encoder when converting instances to binary data, and feed the message(s) into it:

```swift
let message = Message(...)

let encoder = ProtobufEncoder()
let data = try encoder.encode(message)
```

It's also possible to encode single values, arrays, optionals, and dictionaries, so long as they conform to `Codable`.

## Decoding

Decoding instances from binary data works much the same way:

```swift
let decoder = ProtobufDecoder()
let message = decoder.decode(Message.self, from: data)
```

Alternatively, the type can be inferred:

```swift
let message: Message = decoder.decode(from: data)
```

## Coding Keys

The `Codable` protocol uses [CodingKey](https://developer.apple.com/documentation/swift/codingkey) definitions to identify properties of instances. By default, coding keys are generated using the string values of the property names. Similar to JSON encoding, the strings are embedded in the encoded data. Unlike JSON (which is human-readable), the binary representation produced by `ProtobufCodable` is intended for more efficient encoding.

To improve encoding efficiency, it's possible to specify integer coding keys. `Codable` permits this by adding a special enum to conforming types:

```swift
struct Message: Codable {

    enum CodingKeys: Int, CodingKey {
        case sender = 1
        case isRead = 2
        case unreadCount = 3
    }

    var sender: String
    
    var isRead: Bool
    
    var unreadCount: Int
}
```

Using integer keys can significantly decrease the binary size, especially for long property names. Integer coding keys are also required to achieve compatibility with Google's [Protocol Buffers](https://developers.google.com/protocol-buffers).

## Encoding Options

There are currently no encoding options exposed publicly. Additional options may be added in the future.

# Protobuf Compatibility

`ProtobufCodable` aims to provide compatibility with Google's [Protocol Buffers](https://developers.google.com/protocol-buffers) wherever possible. This isn't possible in all cases, since not all Swift features are available in Protobuf, and vice versa.

## Supported types

Protobuf messages are constructed from a limited set of primitives (aka *scalar types*), which are listed in the [official documentation](https://developers.google.com/protocol-buffers/docs/proto3#scalar).

| Protobuf primitive | ProtobufCodable type | Comment |
| --- | --- | --- |
`double` | `Double` | Always 8 bytes
`float` | `Float` | Always 4 bytes
`int32` | `Int32` | Uses variable-length encoding
`int64` | `Int64` | Uses variable-length encoding
`uint32` | `UInt32` | Uses variable-length encoding
`uint64` | `UInt64` | Uses variable-length encoding
`sint32` | `Signed<Int32>` | See [`SignedValue` wrapper](#signed-types)
`sint64` | `Signed<Int64>` |  See [`SignedValue` wrapper](#signed-types)
`fixed32` | `FixedWidth<UInt32>` | See [`FixedWidth` wrapper](#fixed-width-types)
`fixed64` | `FixedWidth<UInt64>` | See [`FixedWidth` wrapper](#fixed-width-types)
`sfixed32` | `FixedWidth<Int32>` | See [`FixedWidth` wrapper](#fixed-width-types)
`sfixed64` | `FixedWidth<Int64>` | See [`FixedWidth` wrapper](#fixed-width-types)
`bool` | `Bool` | Always 1 byte
`string` | `String` | Encoded using UTF-8
`bytes` | `Data` | Encoded as-is

### Supported features

Protobuf primitive | ProtobufCodable equivalent
------------------ | ----------
`repeated type`  | `Array<Type> where Type: Codable` | Fully supported
`map<key,value>` | `Dictionary<Key,Value>` | Fully supported
nested types | nested `Codable` type
`oneof` | Not supported, no straight-forward equivalent
`enum` | Not supported
`Any` | Not supported


## Wrappers

Protobuf encodes integers using [Base 128 variable-length encoding](https://developers.google.com/protocol-buffers/docs/encoding#varints), where smaller values require less bytes to encode. This encoding style is often beneficial, especially when mostly encoding small values. For other cases, different encoding styles may be more optimal.

In order to specify an encoding of integers other than the standard, use one of the property wrappers below.
 
### Fixed-width types

The `@FixedWidth` propery wrapper forces integers to always be encoded using their full width, e.g. using 4 bytes to encode a `UInt32`. In order to apply it to a property, simply specify the wrapper with the property definition:

```swift
struct MyCodable: Codable {

    /// Always encoded as 8 bytes
    @FixedWidth
    var largeInteger: Int64
}
```

The `FixedWidth` wrapper works with `Int16`, `Int32`, `Int64`, `UInt16`, `UInt32`, and `UInt64`.

### Signed types

While the standard variable-length encoding is efficient for small positive values, negative values are encoded with a lot of overhead. To mitigate this, use the `SignedValue` wrapper:

```swift
struct MyCodable: Codable {

    /// Encodes negative values more efficiently
    @SignedValue
    var largeInteger: Int64
}
```

The `SignedValue` wrapper work with `Int16`, `Int32`, and `Int64`

## Merging

Protocol Buffers support the [merging of messages](https://developers.google.com/protocol-buffers/docs/encoding#optional), which overwrites non-repeated fields, and concatenates repeated fields.

`ProtobufCodable` also supports this feature in most cases. This feature is still under development, and should be used with caution.

## Errors

It is possible for both encoding and decoding to fail. 

All possible errors occuring during encoding produce `ProtobufEncodingError` errors, while unsuccessful decoding produces `ProtobufDecodingError`s. Both are enums with several cases describing the nature of the error. See the documentation of the types to learn more about the different error conditions.

# Roadmap

## Check protobuf compatibility

In the future, a runtime feature should be added to check if a type can be fully represented as a Protobuf message. This function should check the `Codable` type for any features (like `Optional`s or `String` keys), which can't be decoded by official Protobuf decoders.

## Generate protobuf definitions

Based on the check for protobuf compatibility, it should be possible to generate a string containing a working Protobuf definition for any type that is determined to be Protobuf compatible.


