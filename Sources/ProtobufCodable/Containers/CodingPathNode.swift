import Foundation

class CodingPathNode {

    let key: CodingKey?

    let codingPath: [CodingKey]

    init(path: [CodingKey], key: CodingKey?) {
        self.codingPath = path
        self.key = key
    }
}
