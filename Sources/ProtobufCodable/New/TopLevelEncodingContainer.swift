import Foundation

final class TopLevelEncodingContainer: Encoder {

    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    private var object: EncodedDataProvider?

    @discardableResult
    func set<T: EncodedDataProvider>(object: T) -> T {
        self.object = object
        return object
    }
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let object = KeyedContainerEncodingNode<Key>(codingPath: codingPath)
        set(object: object)
        return KeyedEncodingContainer(object)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        set(object: UnkeyedContainerEncodingNode(codingPath: codingPath))
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        set(object: SingleValueEncodingNode(codingPath: codingPath))
    }
}

extension TopLevelEncodingContainer: EncodedDataProvider {

    func encodedObjects() throws -> [EncodedDataWrapper] {
        try object?.encodedObjects() ?? []
    }

    func encodedDataToPrepend() throws -> Data {
        try object?.encodedDataToPrepend() ?? .empty
    }

}
