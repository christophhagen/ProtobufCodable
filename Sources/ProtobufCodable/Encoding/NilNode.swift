import Foundation

/**
 A node (leaf) in the encoding tree storing binary data.
 */
final class NilNode: TreeNode {
    
    init(field: Int, userInfo: [CodingUserInfoKey : Any], codingPath: [CodingKey] = []) {
        super.init(type: .nilValue, field: field, userInfo: userInfo, codingPath: codingPath)
    }
    
    init(userInfo: [CodingUserInfoKey : Any], codingPath: [CodingKey] = []) {
        super.init(type: .nilValue, field: nil, userInfo: userInfo, codingPath: codingPath)
    }
    
    /**
     Provide the encoded data.
     
     - Returns: If a field is set, then a `nil` tag is emitted. Otherwise, the data is empty.
     */
    override func getEncodedData() -> Data {
        guard let field = field else {
            return .empty
        }
        return WireType.nilValue.tag(with: field)
    }
    
    override var description: String {
        nodeDescription(forClass: "Data")
    }
}
