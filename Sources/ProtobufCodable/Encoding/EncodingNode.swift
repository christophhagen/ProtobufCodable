import Foundation

class EncodingNode: TreeNode, Encoder {
    
    public var userInfo: [CodingUserInfoKey : Any]
    
    init(parent: TreeNode, key: CodingKey) {
        self.userInfo = [:]
        super.init(type: parent.wireType, field: key.intValue!, codingPath: parent.codingPath + [key])
    }
    
    public init(parent: TreeNode? = nil) {
        self.userInfo = [:]
        super.init(type: parent?.wireType, field: parent?.field, codingPath: parent?.codingPath)
    }

    override func getEncodedData() -> Data {
        children.map { $0.getEncodedData() }.reduce(Data(), +)
    }
    
    // MARK: Encoder
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            KeyedContainer<Key>(encoder: self, parent: self)
        }
        return KeyedEncodingContainer(child)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            UnkeyedContainer(encoder: self, parent: self)
        }
        return child
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        addChild {
            ValueContainer(parent: self)
        }
    }
    
    // MARK: Protocol CustomStringConvertible
    
    override var description: String {
        nodeDescription(forClass: "Node")
    }
}
