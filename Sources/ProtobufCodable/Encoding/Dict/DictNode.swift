import Foundation

final class DictNode: EncodingNode {
    
    override func getEncodedData() -> Data {
        children.map { $0.getEncodedData() }.reduce(Data(), +)
    }
    
    // MARK: Encoder
    
    public override func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            DictKeyedContainer<Key>(encoder: self, parent: self)
        }
        return KeyedEncodingContainer(child)
    }
    
    public override func unkeyedContainer() -> UnkeyedEncodingContainer {
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            DictUnkeyedContainer(encoder: self, parent: self)
        }
        return child
    }
    
    public override func singleValueContainer() -> SingleValueEncodingContainer {
        addChild {
            ValueContainer(parent: self)
        }
    }
    
    // MARK: Protocol CustomStringConvertible
    
    override var description: String {
        nodeDescription(forClass: "Dict")
    }
}
