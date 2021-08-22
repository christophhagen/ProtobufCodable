import Foundation

//struct DictionaryEncodingContainer<Key, Value>: Codable where Key: Hashable, Key: Codable, Value: Codable {
//    
//    let pairs: [(Key, Value)]
//    
//}

struct DictionaryPair<Key, Value>: Codable where Key: Hashable, Key: Codable, Value: Codable {
    
    let key: Key
    
    let value: Value
    
    init(key: Key, value: Value) {
        self.key = key
        self.value = value
    }
    
    enum CodingKeys: Int, CodingKey {
        case key = 1
        case value = 2
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(value, forKey: .value)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(Key.self, forKey: .key)
        let value = try container.decode(Value.self, forKey: .value)
        self.init(key: key, value: value)
    }
}
