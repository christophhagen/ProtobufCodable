import Foundation

final class EnumEncoder: AbstractEncodingNode, SingleValueEncodingContainer {

    private var encodedValue: EncodableContainer?

    func encodeNil() throws {
        throw EncodingError.unsupported(0, "Encoding nil is not supported for Enums", codingPath: codingPath)
    }

    func encode(_ value: Int) throws {
        guard value <= Int32.max && value >= Int32.min else {
            throw EncodingError.unsupported(value, "Enum value must be in the range of Int32", codingPath: codingPath)
        }
        self.encodedValue = value
    }

    func encode(_ value: Int32) throws {
        self.encodedValue = value
    }

    func encode(_ value: Int64) throws {
        guard value <= Int32.max && value >= Int32.min else {
            throw EncodingError.unsupported(value, "Enum value must be in the range of Int32", codingPath: codingPath)
        }
        self.encodedValue = value
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        throw EncodingError.unsupported(value, "Enum must use `RawValue` of `Int`, `Int64` or `Int32`, not \(T.self)", codingPath: codingPath)
    }
}

extension EnumEncoder: EncodableContainer {

    func encode(forKey key: Int) throws -> Data {
        try getElement().encode(forKey: key)
    }

    func encodeForUnkeyedContainer() throws -> Data {
        try getElement().encodeForUnkeyedContainer()
    }

    func getElement() throws -> EncodableContainer {
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No value encoded for enum"))
        }
        return encodedValue
    }
}
