import Foundation

class DictKeyedContainer<Key: CodingKey>: KeyedContainer<Key> {
    
    private enum DictCodingKey: Int, CodingKey {
        case key = 1
        case value = 2
    }
    
    override func getEncodedData() -> Data {
        children.map { $0.getEncodedData() }.reduce(Data(), +)
    }

    override func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let child = addChild {
            KeyedContainer<DictCodingKey>(encoder: encoder, parent: self)
        }
        if let int = key.intValue {
            try child.encode(int, forKey: .key)
        } else {
            try child.encode(key.stringValue, forKey: .key)
        }
        try child.encode(value, forKey: .value)
    }
    
    override var description: String {
        nodeDescription(forClass: "KeyedDict")
    }
}
