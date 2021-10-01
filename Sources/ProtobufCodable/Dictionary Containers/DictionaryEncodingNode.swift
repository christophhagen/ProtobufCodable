import Foundation

/**
 An abstract node to encode a dictionary.
 */
final class DictionaryEncodingNode: CodingPathNode, Encoder {

    let userInfo: [CodingUserInfoKey : Any]

    private var object: EncodedDataProvider?

    init(path: [CodingKey], key: CodingKey?, userInfo: [CodingUserInfoKey : Any]) {
        self.userInfo = userInfo
        super.init(path: path, key: key)
    }

    @discardableResult
    func set<T: EncodedDataProvider>(object: T) -> T {
        self.object = object
        return object
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        // The coding path already includes the key, so it's not added again
        let object = DictionaryKeyedEncodingContainer<Key>(path: codingPath, key: key)
        set(object: object)
        return KeyedEncodingContainer(object)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // The coding path already includes the key, so it's not added again
        set(object: DictionaryUnkeyedEncodingContainer(path: codingPath, key: key))
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        set(object: SingleValueEncodingNode(path: codingPath, key: key))
    }
}

// MARK: EncodedDataProvider

extension DictionaryEncodingNode: EncodedDataProvider {

    func encodedData() throws -> Data {
        // Only pass through the data encoded by the wrapped container
        try object?.encodedData() ?? .empty
    }
}
