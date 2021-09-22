import Foundation

struct EncodedDataWrapper {

    let data: Data

    let wireType: WireType

    let key: CodingKey?

    init(_ data: Data, wireType: WireType = .lengthDelimited, key: CodingKey? = nil) {
        self.data = data
        self.wireType = wireType
        self.key = key
    }

    public var requiresLengthInformationToDecode: Bool {
        wireType == .lengthDelimited
    }

    func with(key: CodingKey) -> EncodedDataWrapper {
        if self.key != nil {
            fatalError()
        }
        return .init(data, wireType: wireType, key: key)
    }

    func encoded(withLengthIfNeeded includeLength: Bool = true) -> Data {
        let data = encodedData(withLengthIfNeeded: includeLength)
        guard let key = key else {
            return data
        }
        #warning("Entry point for non-integer fields")
        let field = key.intValue!
        return wireType.tag(with: field) + data
    }

    private func encodedData(withLengthIfNeeded includeLength: Bool) -> Data {
        if includeLength && requiresLengthInformationToDecode {
            return data.count.variableLengthEncoding + data
        }
        return data
    }
}

struct ComplexEncodingWrapper {

    let data: Data

}

extension ComplexEncodingWrapper: BinaryEncodable {

    var isDefaultValue: Bool {
        false
    }

    static var wireType: WireType {
        .lengthDelimited
    }


    func binaryData() throws -> Data {
        data
    }

    var requiresLengthInformationToDecode: Bool {
        true
    }
}
