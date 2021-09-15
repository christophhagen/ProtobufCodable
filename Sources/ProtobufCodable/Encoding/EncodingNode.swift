import Foundation

class EncodingNode: TreeNode, Encoder {
    
    init(userInfo: [CodingUserInfoKey : Any], parent: TreeNode, key: CodingKey) {
        super.init(type: parent.wireType, field: key.intValue!, userInfo: userInfo, codingPath: parent.codingPath + [key])
    }
    
    init(userInfo: [CodingUserInfoKey : Any]) {
        super.init(userInfo: userInfo)
    }
    
    init(parent: TreeNode) {
        super.init(parent: parent)
    }

    #warning("Only allow a single child for an abstract encoding node")
    override func getEncodedData() -> Data {
        children.map { $0.getEncodedData() }.reduce(Data(), +)
    }
    
    // MARK: Encoder
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            KeyedEncoder<Key>(encoder: self, parent: self)
        }
        return KeyedEncodingContainer(child)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            UnkeyedEncoder(encoder: self, parent: self)
        }
        return child
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        addChild {
            ValueEncoder(parent: self)
        }
    }
    
    // MARK: Protocol CustomStringConvertible
    
    override var description: String {
        nodeDescription(forClass: "Node")
    }
}
