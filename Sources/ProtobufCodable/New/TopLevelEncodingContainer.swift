import Foundation

protocol EncodedDataProvider {
    
    func getEncodedData() throws -> Data
}

final class TopLevelEncodingContainer: Encoder {

    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    private var wrappedContainer: EncodedDataProvider?
    
    func setContainer<T: EncodedDataProvider>(_ container: T) -> T {
        self.wrappedContainer = container
        return container
    }
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        fatalError()
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        setContainer(SingleValueEncodingNode(codingPath: codingPath))
    }
}

extension TopLevelEncodingContainer: EncodedDataProvider {
    
    func getEncodedData() throws -> Data {
        try wrappedContainer?.getEncodedData() ?? .empty
    }
}
