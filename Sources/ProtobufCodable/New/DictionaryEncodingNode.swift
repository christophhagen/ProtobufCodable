import Foundation

final class DictionaryEncodingNode: Encoder {

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

    private var wrappedContainer: EncodedDataProvider?

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = DictionaryKeyedEncodingContainer<Key>(codingPath: codingPath)
        self.wrappedContainer = container
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = DictionaryUnkeyedEncodingContainer(codingPath: codingPath)
        self.wrappedContainer = container
        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension DictionaryEncodingNode: EncodedDataProvider {

    func getEncodedData() throws -> Data {
        guard let data = try wrappedContainer?.getEncodedData() else {
            fatalError()
        }
        return data
    }

    func encodedObjects() throws -> [Data] {
        try wrappedContainer?.encodedObjects() ?? []
    }
}
