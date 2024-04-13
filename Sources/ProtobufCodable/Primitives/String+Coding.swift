import Foundation

extension String: EncodablePrimitive {

    var protoTypeName: String {
        "string"
    }

    static var zero: String {
        ""
    }

    var encodedData: Data {
        data(using: .utf8)!
    }
}

extension String: DecodablePrimitive {

    static var wireType: WireType {
        .len
    }

    init(data: Data) throws {
        guard let value = String(data: data, encoding: .utf8) else {
            throw CorruptedDataError(invalidString: data.count)
        }
        self = value
    }
}

// MARK: - ProtobufMapKey

extension String: ProtobufMapKey {

}
