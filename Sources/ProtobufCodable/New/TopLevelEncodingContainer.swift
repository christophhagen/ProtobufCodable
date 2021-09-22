import Foundation

final class TopLevelEncodingContainer: Encoder {

    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    private var wrappedContainer: EncodedDataProvider?

    @discardableResult
    func setContainer<T: EncodedDataProvider>(_ container: T) -> T {
        self.wrappedContainer = container
        return container
    }
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = KeyedContainerEncodingNode<Key>(codingPath: codingPath)
        setContainer(container)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        setContainer(UnkeyedContainerEncodingNode(codingPath: codingPath))
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        setContainer(SingleValueEncodingNode(codingPath: codingPath))
    }
}

extension TopLevelEncodingContainer: EncodedDataProvider {

    
    func getEncodedData() throws -> Data {
        try wrappedContainer?.getEncodedData() ?? .empty
    }

    func encodedObjects() throws -> [Data] {
        try wrappedContainer?.encodedObjects() ?? []
    }

    func encodedDataToPrepend() throws -> Data {
        try wrappedContainer?.encodedDataToPrepend() ?? .empty
    }

}
