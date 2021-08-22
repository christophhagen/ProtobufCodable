import Foundation

class TreeNode {
    
    var codingPath: [CodingKey]
    
    /// The wire type of the field encoded in this node
    var wireType: WireType?
    
    /// The field associated with the node
    var field: Int?
    
    /// The elements contained in this structure
    var children: [TreeNode]
    
    init(type: WireType? = nil, field: Int? = nil, codingPath: [CodingKey]? = []) {
        self.wireType = type
        self.field = field
        self.codingPath = codingPath ?? []
        self.children = []
    }
    
    convenience init(parent: TreeNode?) {
        self.init(type: parent?.wireType, field: parent?.field, codingPath: parent?.codingPath)
    }
    
    var needsEncodingWhenEmpty: Bool {
        true
    }
    
    func getEncodedData() -> Data {
        let data = children.map { $0.getEncodedData() }.reduce(Data(), +)
        guard let type = wireType, let field = field else {
            return data
        }
        let tag = type.tag(with: field)
        guard type == .lengthDelimited else {
            return tag + data
        }
        return tag + data.count.variableLengthEncoding + data
    }
    
    func printTree(indentation: String = "") {
        print("\(indentation)\(self)")
        for child in children {
            child.printTree(indentation: indentation + "  ")
        }
    }
    
    private var typeString: String {
        guard let type = wireType else {
            return "none"
        }
        return type.description
    }
    
    private var fieldString: String {
        guard let field = field else {
            return "none"
        }
        return "\(field)"
    }
    
    var path: String {
        ".root" + codingPath.map { "." + $0.stringValue }.joined()
    }
    
    func description(forClass className: String) -> String {
        "\(className) \(path) (\(typeString), \(fieldString)): \(children.count) nodes -> \(getEncodedData().bytes)"
    }
    
    @discardableResult
    func addChild<T>(_ block: () throws -> T) rethrows -> T where T: TreeNode {
        let child = try block()
        children.append(child)
        return child
    }

}
