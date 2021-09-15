import Foundation

class UnkeyedEncoder: TreeNode, UnkeyedEncodingContainer {
    
    let encoder: Encoder
    
    var count: Int = 0
    
    private var nilIndices: Set<Int> = []
    
    /// Indicates if primitive values are encoded, to determine if the tag must be included for each container
    private var encodesPrimitives = false
    
    init(encoder: Encoder, parent: TreeNode, key: CodingKey) {
        self.encoder = encoder
        super.init(type: parent.wireType,
                   field: key.intValue!,
                   userInfo: parent.userInfo,
                   codingPath: parent.codingPath + [key])
    }
    
    init(encoder: Encoder, parent: TreeNode?) {
        self.encoder = encoder
        super.init(parent: parent)
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
            // Complex types already include the tag, so no additional work necessary.
            return data
        }
        guard let type = wireType, let field = field else {
            // No field means that we're encoding an array directly
            // So append the nil index info and return the whole thing
            #warning("Which circumstances lead to missing field id for unkeyed container?")
            return data
        }
        let tag = type.tag(with: field)
        guard type == .lengthDelimited else {
            return tag + data
        }
        return tag + data.count.variableLengthEncoding + data
    }
    
    private func getNilData() -> Data {
        let nilData = nilIndices.sorted().map { UInt32($0).variableLengthEncoding }.reduce(Data.empty, +)
        let nilLength = UInt32(nilIndices.count).variableLengthEncoding
        return nilLength + nilData
    }
    
    func encodeNil() throws {
        nilIndices.insert(count)
        count += 1
    }

    private func encodeBinary(_ binary: BinaryEncodable) throws {
        // Note: Default values are encoded in repeated fields
        try addChild {
            DataNode(data: try binary.binaryData(),
                     userInfo: userInfo,
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
        switch value {
        case let binary as BinaryEncodable:
            try encodeBinary(binary)
        default:
            try encodeChild(value)
        }
        count += 1
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let child = addChild {
            KeyedEncoder<NestedKey>(encoder: encoder, parent: self)
        }
        if wireType == nil && field != nil {
            wireType = .lengthDelimited
        }
        return KeyedEncodingContainer(child)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let child = addChild {
            UnkeyedEncoder(encoder: encoder, parent: self)
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
