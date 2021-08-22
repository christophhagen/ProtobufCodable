import Foundation

final class EncodingNode: TreeNode, Encoder {
    
    public var userInfo: [CodingUserInfoKey : Any] {
        didSet { trace() }
    }
    
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
        trace("path \(path), keyedBy: \(type)")
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild { PBKeyedEncodingContainer<Key>(encoder: self, parent: self) }
        return KeyedEncodingContainer(child)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        trace("path \(path)")
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        let child = addChild {
            PBUnkeyedEncodingContainer(encoder: self, parent: self)
        }
        return child
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        trace("path \(path)")
        return addChild {
            PBValueContainer(parent: self)
        }
    }
}

// MARK: Protocol CustomStringConvertible

extension EncodingNode: CustomStringConvertible {
    
    var fieldDescription: String {
        guard let f = field else {
            return "No field"
        }
        return "Field \(f)"
    }
    
    var description: String {
        description(forClass: "Node")
    }
}
