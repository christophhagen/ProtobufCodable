import Foundation

final class DictionaryEncodingNode: Encoder {

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

    private var object: EncodedDataProvider?

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    @discardableResult
    func set<T: EncodedDataProvider>(object: T) -> T {
        self.object = object
        return object
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let object = DictionaryKeyedEncodingContainer<Key>(codingPath: codingPath)
        set(object: object)
        return KeyedEncodingContainer(object)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        set(object: DictionaryUnkeyedEncodingContainer(codingPath: codingPath))
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension DictionaryEncodingNode: EncodedDataProvider {

    func encodedObjects() throws -> [EncodedDataWrapper] {
        try object?.encodedObjects() ?? []
    }

    func encodedDataToPrepend() throws -> Data {
        try object?.encodedDataToPrepend() ?? .empty
    }
}
