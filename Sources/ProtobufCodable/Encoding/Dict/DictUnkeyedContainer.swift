import Foundation

final class DictUnkeyedContainer: PBUnkeyedEncodingContainer {
    
    private enum DictCodingKey: Int, CodingKey {
        case key = 1
        case value = 2
    }
    
    /// Indicates if primitive values are encoded, to determine if the tag must be included for each container
    private var encodesPrimitives = false
    
    private var currentPairContainer: PBKeyedEncodingContainer<DictCodingKey>?

    override func getEncodedData() -> Data {
        children.map { $0.getEncodedData() }.reduce(Data(), +)
    }

    private func encodeKey<K>(_ key: K) throws where K : Encodable {
        let container = PBKeyedEncodingContainer<DictCodingKey>(encoder: encoder, parent: self)
        try container.encode(key, forKey: .key)
        self.currentPairContainer = container
    }
    
    override func encode<T>(_ value: T) throws where T : Encodable {
        guard let container = currentPairContainer else {
            try encodeKey(value)
            return
        }
        try container.encode(value, forKey: .value)
        addChild { container }
        count += 1
        currentPairContainer = nil
    }
    
    override var description: String {
        description(forClass: "DictUnkeyed")
    }
}
