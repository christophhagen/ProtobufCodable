import Foundation

final class TopLevelEncoder: AbstractEncodingNode, Encoder {

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

    init(userInfo: [CodingUserInfoKey : Any]) {
        super.init(codingPath: [], userInfo: userInfo)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        .init(assign(
            KeyedEncoder<Key>(codingPath: codingPath, userInfo: userInfo)
        ))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder("Unkeyed containers at the top level are not supported")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        UnsupportedValueEncoder("Single value containers at the top level are not supported")
    }
}

extension TopLevelEncoder {

    func containedData() throws -> Data {
        guard !hasMultipleCalls else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Multiple calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        return try encodedValue.encodeForUnkeyedContainer()
    }
}
