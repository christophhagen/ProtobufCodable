import Foundation

class DecodingTreeNode {
    
    var codingPath: [CodingKey]
    
    let data: Data
    
    /// The elements contained in this structure
    var children: [DecodingTreeNode]
    
    /**
     Create a new tree node.
     
     - Parameter codingPath: The coding path leading to the node.
     */
    init(data: Data, codingPath: [CodingKey]? = []) {
        self.data = data
        self.codingPath = codingPath ?? []
        self.children = []
    }
    
    /**
     Create a new node as a child of another node.
     
     - Parameter parent: The parent node.
     - Note: Specify `nil` for the parent to create a root node.
     - Note: The coding path is automatically inherited from the parent node.
     */
    convenience init(data: Data, parent: DecodingTreeNode?) {
        self.init(data: data, codingPath: parent?.codingPath)
    }
}
