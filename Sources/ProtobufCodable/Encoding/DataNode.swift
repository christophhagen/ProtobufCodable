import Foundation

/**
 A node (leaf) in the encoding tree storing binary data.
 */
final class DataNode: TreeNode {
    
    /// The binary data stored in the node
    private let data: Data
    
    init(data: Data, type: WireType? = nil, field: Int? = nil, codingPath: [CodingKey] = []) {
        self.data = data
        super.init(type: type, field: field, codingPath: codingPath)
    }
    
    /**
     Provide the encoded data.
     
     If a wire type and field exist for the node, then a tag is prepended to the data.
     If the wire type is `lengthDelimited`, then the number of bytes in the data is added after the tag, and before the data.
     - Returns: The binary data.
     */
    override func getEncodedData() -> Data {
        guard let type = wireType, let field = field else {
            return data
        }
        let tag = type.tag(with: field)
        guard type == .lengthDelimited else {
            return tag + data
        }
        return tag + data.count.variableLengthEncoding + data
    }
    
    override var description: String {
        nodeDescription(forClass: "Data")
    }
}
