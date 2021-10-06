import Foundation

final class TopLevelEncoder: CodingPathNode, Encoder {

    let userInfo: [CodingUserInfoKey : Any]
    
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
        let object = KeyedEncoder<Key>(path: codingPath, key: key)
        set(object: object)
        return KeyedEncodingContainer(object)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        set(object: UnkeyedEncoder(path: codingPath, key: key))
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        set(object: ValueEncoder(path: codingPath, key: key))
    }
}

extension TopLevelEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        try object?.encodedData() ?? .empty
    }
}
