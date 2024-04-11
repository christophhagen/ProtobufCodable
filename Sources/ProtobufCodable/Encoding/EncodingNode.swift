import Foundation

final class EncodingNode: AbstractEncodingNode, Encoder {

    private var hasMultipleCalls = false

    private var encodedValue: EncodableContainer? = nil

    private func assign<T>(_ value: T) -> T where T: EncodableContainer {
        // Prevent multiple calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()
        if encodedValue == nil {
            encodedValue = value
        } else {
            hasMultipleCalls = true
        }
        return value
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(assign(KeyedEncoder<Key>(codingPath: codingPath, userInfo: userInfo)))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assign(UnkeyedEncoder(codingPath: codingPath, userInfo: userInfo))
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        // Only enums with `RawValue == Int` are allowed to use single value containers
        assign(EnumEncoder(codingPath: codingPath, userInfo: userInfo))
    }
}

extension EncodingNode: EncodableContainer {

    func encode(forKey key: Int) throws -> Data {
        try getEncodedValue().encode(forKey: key)
    }

    func encodeForUnkeyedContainer() throws -> Data {
        try getEncodedValue().encodeForUnkeyedContainer()
    }

    private func throwErrorOnMultipleCalls() throws {
        guard hasMultipleCalls else { return }
        throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Multiple calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
    }

    private func getEncodedValue() throws -> EncodableContainer {
        guard !hasMultipleCalls else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Multiple calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        return encodedValue
    }
}
