import Foundation

// MARK: TopLevelEncoder
/**
 Encodes an instance on the top level as the entry point for encoding.
 
 It is also used to encode nested containers.
 */
final class TopLevelEncoder: CodingPathNode {
    
    // MARK: Properties

    private var object: EncodedDataProvider?

    let requiresLength: Bool

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], requiresLength: Bool = false) {
        self.requiresLength = requiresLength
        super.init(path: path, key: key, info: info)
    }
    
    @discardableResult
    private func set<T: EncodedDataProvider>(object: T) -> T {
        self.object = object
        return object
    }
}

// MARK: Encoder

extension TopLevelEncoder: Encoder {

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let object = KeyedEncoder<Key>(path: codingPath, key: key, info: userInfo, requiresLength: requiresLength)
        set(object: object)
        return KeyedEncodingContainer(object)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        set(object: UnkeyedEncoder(path: codingPath, key: key, info: userInfo))
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        set(object: ValueEncoder(path: codingPath, key: key, info: userInfo, requiresLength: requiresLength))
    }
}

// MARK: EncodedDataProvider

extension TopLevelEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        try object?.encodedData() ?? .empty
    }
}
