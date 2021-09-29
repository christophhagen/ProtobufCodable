import Foundation

struct NilContainer: BinaryEncodable {

    func binaryData() -> Data {
        .empty
    }

    var isDefaultValue: Bool {
        false
    }

    static let wireType: WireType = .nilValue
}
