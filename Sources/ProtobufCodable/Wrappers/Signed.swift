import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format as a zig-zag encoded integer.

 Use the property wrapped within a `Codable` definition to enforce zig-zag encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Encoded using zig-zag encoding
     @ZigZagEncoded
     var myValue: Int16
 }
 ```

 Integers in `BinaryCodable` are normally encoded using zig-zag encoding (`UInt`, `UInt32`, `UInt64`, `Int`, `Int32`, `Int64`) or fixed-length encoding (`UInt16`, `Int16`).
 The `@ZigZagEncoded` property wrapper forces values of type `Int16` to be encoded using standard zig-zag encoding.
 The wrapper has no effect on `Int`, `Int32`, and `Int64`.

 This encoding:
 - Can be more efficient compared to fixed-length encoding for small values.
 - Is more efficient compared to variable-length encoded values if number are negative.

 The `ZigZagEncoded` property wrapper is supported for `Int`, `Int16`, `Int32`, and `Int64`.

 - Warning: Do not conform other types to `ZigZagCodable`. This will lead to crashes during encoding and decoding.
 - SeeAlso: [Protobuf Language Guide: Scalar value types](https://developers.google.com/protocol-buffers/docs/proto3#scalar)
 */
@propertyWrapper
public struct Signed<WrappedValue> where WrappedValue: SignedCodable, WrappedValue: Codable, WrappedValue: FixedWidthInteger, WrappedValue: SignedInteger {

    /// The value wrapped in the zig-zag encoding container
    public var wrappedValue: WrappedValue

    /**
     Wrap an integer value in a zig-zag encoding container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}

extension Signed: EncodablePrimitive {

    var protoTypeName: String {
        wrappedValue.signedProtoTypeName
    }

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    var encodedData: Data {
        wrappedValue.signedEncoded
    }
}

extension Signed: DecodablePrimitive {

    static var wireType: WireType {
        .varInt
    }

    init(data: Data) throws {
        let wrappedValue = try WrappedValue(fromSigned: data)
        self.init(wrappedValue: wrappedValue)
    }
}

extension Signed: Encodable {

    /**
     Encode the wrapped value transparently to the given encoder.
     - Parameter encoder: The encoder to use for encoding.
     - Throws: Errors from the decoder when attempting to encode a value in a single value container.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension Signed: Decodable {
    /**
     Decode a wrapped value from a decoder.
     - Parameter decoder: The decoder to use for decoding.
     - Throws: Errors from the decoder when reading a single value container or decoding the wrapped value from it.
     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(WrappedValue.self)
    }
}

// MARK: - Packable

extension Signed: Packable {

}

// MARK: - ProtobufMapKey

extension Signed: ProtobufMapKey {

}

// MARK: - Integer conformances

extension Signed: Numeric {
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let wrapped = WrappedValue(exactly: source) else {
            return nil
        }
        self.init(wrappedValue: wrapped)
    }

    public var magnitude: WrappedValue.Magnitude {
        wrappedValue.magnitude
    }

    public static func * (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Signed<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue * rhs.wrappedValue)
    }

    public static func *= (lhs: inout Signed<WrappedValue>, rhs: Signed<WrappedValue>) {
        lhs.wrappedValue *= rhs.wrappedValue
    }
}

extension Signed: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, x + .zero == x and .zero + x == x.
     */
    public static var zero: Self {
        .init(wrappedValue: .zero)
    }

    public static func - (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Signed<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue - rhs.wrappedValue)
    }

    public static func + (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Signed<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue + rhs.wrappedValue)
    }
}

extension Signed: BinaryInteger {

    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(wrappedValue: .init(source))
    }

    public static var isSigned: Bool {
        WrappedValue.isSigned
    }

    public var words: WrappedValue.Words {
        wrappedValue.words
    }

    public var trailingZeroBitCount: Int {
        wrappedValue.trailingZeroBitCount
    }

    public static func / (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Signed<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue / rhs.wrappedValue)
    }

    public static func % (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Signed<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue % rhs.wrappedValue)
    }

    public static func /= (lhs: inout Signed<WrappedValue>, rhs: Signed<WrappedValue>) {
        lhs.wrappedValue /= rhs.wrappedValue
    }

    public static func %= (lhs: inout Signed<WrappedValue>, rhs: Signed<WrappedValue>) {
        lhs.wrappedValue %= rhs.wrappedValue
    }

    public static func &= (lhs: inout Signed<WrappedValue>, rhs: Signed<WrappedValue>) {
        lhs.wrappedValue &= rhs.wrappedValue
    }

    public static func |= (lhs: inout Signed<WrappedValue>, rhs: Signed<WrappedValue>) {
        lhs.wrappedValue |= rhs.wrappedValue
    }

    public static func ^= (lhs: inout Signed<WrappedValue>, rhs: Signed<WrappedValue>) {
        lhs.wrappedValue ^= rhs.wrappedValue
    }
}

extension Signed: FixedWidthInteger {

    public typealias Words = WrappedValue.Words

    public typealias Magnitude = WrappedValue.Magnitude

    public init<T>(_truncatingBits source: T) where T : BinaryInteger {
        self.init(wrappedValue: .init(source))
    }

    public func dividingFullWidth(_ dividend: (high: Signed<WrappedValue>, low: WrappedValue.Magnitude)) -> (quotient: Signed<WrappedValue>, remainder: Signed<WrappedValue>) {
        let result = wrappedValue.dividingFullWidth((high: dividend.high.wrappedValue, low: dividend.low))
        return (quotient: Signed(wrappedValue: result.quotient), remainder: Signed(wrappedValue: result.remainder))
    }

    public func addingReportingOverflow(_ rhs: Signed<WrappedValue>) -> (partialValue: Signed<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.addingReportingOverflow(rhs.wrappedValue)
        return (Signed(wrappedValue: result.partialValue), result.overflow)
    }

    public func subtractingReportingOverflow(_ rhs: Signed<WrappedValue>) -> (partialValue: Signed<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.subtractingReportingOverflow(rhs.wrappedValue)
        return (Signed(wrappedValue: result.partialValue), result.overflow)
    }

    public func multipliedReportingOverflow(by rhs: Signed<WrappedValue>) -> (partialValue: Signed<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.multipliedReportingOverflow(by: rhs.wrappedValue)
        return (Signed(wrappedValue: result.partialValue), result.overflow)
    }

    public func dividedReportingOverflow(by rhs: Signed<WrappedValue>) -> (partialValue: Signed<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.dividedReportingOverflow(by: rhs.wrappedValue)
        return (Signed(wrappedValue: result.partialValue), result.overflow)
    }

    public func remainderReportingOverflow(dividingBy rhs: Signed<WrappedValue>) -> (partialValue: Signed<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.remainderReportingOverflow(dividingBy: rhs.wrappedValue)
        return (Signed(wrappedValue: result.partialValue), result.overflow)
    }

    public static var bitWidth: Int {
        WrappedValue.bitWidth
    }

    public var nonzeroBitCount: Int {
        wrappedValue.nonzeroBitCount
    }

    public var leadingZeroBitCount: Int {
        wrappedValue.leadingZeroBitCount
    }

    public var byteSwapped: Signed<WrappedValue> {
        .init(wrappedValue: wrappedValue.byteSwapped)
    }

    /// The maximum representable integer in this type.
    ///
    /// For unsigned integer types, this value is `(2 ** bitWidth) - 1`, where
    /// `**` is exponentiation. For signed integer types, this value is
    /// `(2 ** (bitWidth - 1)) - 1`.
    public static var max: Self {
        .init(wrappedValue: .max)
    }

    /// The minimum representable integer in this type.
    ///
    /// For unsigned integer types, this value is always `0`. For signed integer
    /// types, this value is `-(2 ** (bitWidth - 1))`, where `**` is
    /// exponentiation.
    public static var min: Self {
        .init(wrappedValue: .min)
    }
}

extension Signed: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = WrappedValue.IntegerLiteralType

    public init(integerLiteral value: WrappedValue.IntegerLiteralType) {
        self.wrappedValue = WrappedValue.init(integerLiteral: value)
    }
}

extension Signed: Equatable {

    public static func == (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Signed: Comparable {

    public static func < (lhs: Signed<WrappedValue>, rhs: Signed<WrappedValue>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }
}

extension Signed: Hashable { }
