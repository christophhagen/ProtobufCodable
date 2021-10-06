import Foundation

/**
 An abstract node to encode a dictionary.
 */
final class DictionaryEncoder: CodingPathNode, Encoder {

    private var object: EncodedDataProvider?

    @discardableResult
    func set<T: EncodedDataProvider>(object: T) -> T {
        self.object = object
        return object
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        // The coding path already includes the key, so it's not added again
        let object = DictionaryKeyedEncoder<Key>(path: codingPath, key: key, info: userInfo)
        set(object: object)
        return KeyedEncodingContainer(object)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // The coding path already includes the key, so it's not added again
        set(object: DictionaryUnkeyedEncoder(path: codingPath, key: key, info: userInfo))
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        set(object: ValueEncoder(path: codingPath, key: key, info: userInfo))
    }
}

// MARK: EncodedDataProvider

extension DictionaryEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        // Only pass through the data encoded by the wrapped container
        try object?.encodedData() ?? .empty
    }
}
