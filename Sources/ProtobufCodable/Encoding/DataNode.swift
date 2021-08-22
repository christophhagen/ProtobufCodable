import Foundation


final class DataNode: TreeNode {
    
    private let data: Data
    
    init(data: Data, type: WireType? = nil, field: Int? = nil, codingPath: [CodingKey] = []) {
        self.data = data
        super.init(type: type, field: field, codingPath: codingPath)
    }
    
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
}

extension DataNode: CustomStringConvertible {
    
    var description: String {
        description(forClass: "Data")
//        let data = getEncodedData()
//        return "Data \(path): \(data) -> \(data.bytes)"
    }
}
