import Foundation

/**
 A tree node is a generic node in the encoding tree which is traversed by the encoder during encoding.
 
 It stores a number of children, as well as other encoding information, such as a possible tag.
 After the full tree is traversed, the binary data can be collected
 */
class TreeNode: CustomStringConvertible {
    
    var codingPath: [CodingKey]
    
    /// The wire type of the field encoded in this node
    var wireType: WireType?
    
    /// The field associated with the node
    var field: Int?
    
    /// The elements contained in this structure
    var children: [TreeNode]
    
    /// Indicate that the node should be encoded in the binary, even when it produces no data (required for default values in repeated fields)
    var needsEncodingWhenEmpty: Bool {
        true
    }
    
    // MARK: Initialization
    
    /**
     Create a new tree node.
     
     - Parameter type: The wire type of the enclosed object, if applicable
     - Parameter field: The field number of the enclosed object, if applicable
     - Parameter codingPath: The coding path leading to the node.
     */
    init(type: WireType? = nil, field: Int? = nil, codingPath: [CodingKey]? = []) {
        self.wireType = type
        self.field = field
        self.codingPath = codingPath ?? []
        self.children = []
    }
    
    /**
     Create a new node as a child of another node.
     
     - Parameter parent: The parent node.
     - Note: Specify `nil` for the parent to create a root node.
     - Note: Wire type, field and coding path are automatically inherited from the parent node.
     */
    convenience init(parent: TreeNode?) {
        self.init(type: parent?.wireType, field: parent?.field, codingPath: parent?.codingPath)
    }
    
    // MARK: Encoding
    
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
    
    @discardableResult
    func addChild<T>(_ block: () throws -> T) rethrows -> T where T: TreeNode {
        let child = try block()
        children.append(child)
        return child
    }
    
    // MARK: Debugging
    
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

    var description: String {
        description(forClass: "TreeNode")
    }
}
