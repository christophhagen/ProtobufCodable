import Foundation

class UnkeyedContainer: TreeNode, UnkeyedEncodingContainer {
    
    var encoder: Encoder
    
    var count: Int = 0
    
    /// Indicates if primitive values are encoded, to determine if the tag must be included for each container
    private var encodesPrimitives = false
    
    init(encoder: Encoder, parent: TreeNode, key: CodingKey) {
        self.encoder = encoder
        super.init(type: parent.wireType, field: key.intValue!, codingPath: parent.codingPath + [key])
    }
    
    init(encoder: Encoder, parent: TreeNode?) {
        self.encoder = encoder
        super.init(type: parent?.wireType, field: parent?.field, codingPath: parent?.codingPath)
    }
    
    override var needsEncodingWhenEmpty: Bool {
        false
    }
    
    override func getEncodedData() -> Data {
        let data = children.map { $0.getEncodedData() }.reduce(Data(), +)
        guard !data.isEmpty else {
            return .empty
        }
        guard encodesPrimitives else {
            return data
        }
        guard let type = wireType, let field = field else {
            return data
        }
        let tag = type.tag(with: field)
        guard type == .lengthDelimited else {
            return tag + data
        }
        return tag + data.count.variableLengthEncoding + data
    }
    
    func encodeNil() throws {
        throw ProtobufEncodingError.notImplemented
    }

    private func encodeBinary(_ binary: BinaryEncodable) throws {
        // Note: Default values are encoded in repeated fields
        try addChild {
            DataNode(data: try binary.binaryData(),
                     type: binary.wireType,
                     codingPath: codingPath)
        }
        encodesPrimitives = true
    }
    
    private func encodeChild(_ value: Encodable) throws {
        let child = addChild {
            EncodingNode(parent: self)
        }
        encodesPrimitives = false
        try value.encode(to: child)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        count += 1
        switch value {
        case let binary as BinaryEncodable:
            try encodeBinary(binary)
        default:
            try encodeChild(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let child = addChild {
            KeyedContainer<NestedKey>(encoder: encoder, parent: self)
        }
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        return KeyedEncodingContainer(child)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let child = addChild {
            UnkeyedContainer(encoder: encoder, parent: self)
        }
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        return child
    }
    
    func superEncoder() -> Encoder {
        encoder
    }
    
    override var description: String {
        nodeDescription(forClass: "Unkeyed")
    }
}
