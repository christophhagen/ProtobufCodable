import Foundation

private extension DecodingDataProvider {

    func getTag() throws -> (field: Int, wireType: WireType) {
        let value = try Int(from: self)
        let field = value >> 3
        let wireType = WireType(rawValue: value & 0x7)!
        return (field, wireType)
    }
}

private func createTag(field: Int, wireType: WireType) -> Data {
    let typeAndTag = (field << 3) | wireType.rawValue
    return typeAndTag.binaryData()
}

struct Tag: ByteDecodable {

    let wireType: WireType

    let key: CodingKey

    init(type: WireType, key: CodingKey) {
        self.wireType = type
        self.key = key
    }

    init(from byteProvider: DecodingDataProvider) throws {
        let (field, wireType) = try byteProvider.getTag()
        guard wireType == .stringKey else {
            self.wireType = wireType
            self.key = GenericCodingKey(field)
            return
        }
        print("String key found, \(field) bytes")
        // For a string key, the field number signals the key length
        let keyData = try byteProvider.getNextBytes(field)
        print("Key: \(keyData.bytes)")
        let stringKey = try String(from: .init(data: keyData))
        print("Key: \(stringKey)")
        // The real wire type follows after the string
        let realWireType = try byteProvider.getTag().wireType
        print("Wire type: \(realWireType)")
        self.wireType = realWireType
        self.key = GenericCodingKey(stringKey)
    }

    /**
     Create a tag (field number + wire type).

     Each key in the streamed message is a `varint` with the value `(field_number << 3) | wire_type` – in other words, the last three bits of the number store the wire type. The definition of the tag/key encoding is available in the [Protocol Buffer Message Structure](https://developers.google.com/protocol-buffers/docs/encoding#structure) documentation.
     */
    func data() throws -> Data {
        guard let field = key.intValue else {
            let stringData = try key.stringValue.binaryData()
            let stringTag = createTag(field: stringData.count, wireType: .stringKey)
            let fieldTag = createTag(field: 0, wireType: wireType)
            print("Field '\(key.stringValue)' (length \(stringData.count), tag: \(stringTag.bytes), field tag: \(fieldTag.bytes)")
            return stringTag + stringData + fieldTag
        }
        return createTag(field: field, wireType: wireType)
    }

    var nilKey: GenericCodingKey {
        key.correspondingNilKey
    }

    var dictionaryKey: KeyValueCodingKey? {
        .init(key: key)
    }

    var requiresLengthDecoding: Bool {
        wireType == .lengthDelimited
    }

    var valueLength: Int? {
        switch wireType {
        case .length64:
            return 8
        case .nilValue:
            return 0
        case .length32:
            return 4
        case .length8:
            return 1
        case .length16:
            return 2
        default:
            return nil
        }
    }
}
