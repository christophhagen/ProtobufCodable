import Foundation

/**
 The data type specifying how a value is encoded on the wire.

 The data type is mixed into the key for each value to indicate how many bytes the value occupies in the following bytes.

 The data type is equivalent to the [Protocol Buffer Wire Type](https://developers.google.com/protocol-buffers/docs/encoding#structure), but extended to support more data types.
 */
public enum WireType: Int {

    /**
     An integer value encoded as a Base128 Varint.
     The length can be determined by reading the value,
     where the first (MSB) indicates whether another byte follows.
     A Varint consumes up to 10 bytes.

     See also [Protocol Buffers: Base 128 Varints](https://developers.google.com/protocol-buffers/docs/encoding#varints).

     Proto types: `int32`, `int64`, `uint32`, `uint64`, `sint32`, `sint64`, `bool`, `enum`

     Swift types: `Int32`, `Int64`,  `Int`, `UInt32`, `UInt`, `UInt64`, `Bool`, enums where `RawValue == Int`
     */
    case varInt = 0

    /**
     The value is encoded using eight bytes.

     Proto types: `fixed64`, `sfixed64`, `double`

     Used by: `Fixed<UInt64>`, `Fixed<UInt>`, `Fixed<Int64>`, `Fixed<Int>`, `Double`
     */
    case i64 = 1

    /**
     The value is encoded using first a length (as a UInt64 var-int) followed by the bytes.

     Proto types: `string`, `bytes`, `embedded messages`, `packed repeated fields`

     Swift types: `String`, `Data`, `struct`, arrays of primitive types
     */
    case len = 2

    /**
     The value is encoded using four bytes.

     Proto types: `fixed32`, `sfixed32`, `float`

     Swift types: , `Fixed<UInt32>`, `Fixed<Int32>`, `Float`
     */
    case i32 = 5

    /**
     Decode a data type from an integer tag.

     The integer tag includes both the integer field key (or string key length) and the data type,
     where the data type is encoded in the three LSB.
     - Parameter value: The raw tag value.
     - Throws: `DecodingError.dataCorrupted()`, if the data type is unknown (3 or 4)
     */
    init?(decodeFrom value: Int) {
        let rawDataType = value & 0x7
        self.init(rawValue: rawDataType)
    }
}

extension WireType {

    func encoded(with key: Int) -> Data {
        let mixed = (key << 3) | rawValue
        return mixed.variableLengthEncoded
    }
}

extension WireType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .varInt:
            return "VarInt"
        case .i64:
            return "64 Bit"
        case .len:
            return "VarLen"
        case .i32:
            return "32 Bit"
        }
    }
}
