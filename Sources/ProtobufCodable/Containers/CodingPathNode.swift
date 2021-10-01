import Foundation

/**
 An abstract node specifying a coding path within a codable container.
 */
class CodingPathNode {

    /**
     The key associated with the current path.

     If the key is nil, then the node is at the top level.
     */
    let key: CodingKey?

    /**
     The path taken to reach the node within the value to encode/decode.
     */
    let codingPath: [CodingKey]

    /**
     Create a new node.
     - Parameter path: The coding path to the node, including the node's key.
     - Parameter key: The key associated with the node.
     */
    init(path: [CodingKey], key: CodingKey?) {
        self.codingPath = path
        self.key = key
    }
}
