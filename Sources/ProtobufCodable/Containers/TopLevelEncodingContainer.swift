import Foundation

final class TopLevelEncodingContainer: CodingPathNode, Encoder {

    var userInfo: [CodingUserInfoKey : Any]
    
    private var object: EncodedDataProvider?

    @discardableResult
    func set<T: EncodedDataProvider>(object: T) -> T {
        self.object = object
        return object
    }
    
    init(path: [CodingKey], key: CodingKey?, userInfo: [CodingUserInfoKey : Any]) {
        self.userInfo = userInfo
        super.init(path: path, key: key)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let object = KeyedContainerEncodingNode<Key>(path: codingPath, key: key)
        set(object: object)
        return KeyedEncodingContainer(object)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        set(object: UnkeyedContainerEncodingNode(path: codingPath, key: key))
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        set(object: SingleValueEncodingNode(path: codingPath, key: key))
    }
}

extension TopLevelEncodingContainer: EncodedDataProvider {

    func encodedData() throws -> Data {
        try object?.encodedData() ?? .empty
    }
}
