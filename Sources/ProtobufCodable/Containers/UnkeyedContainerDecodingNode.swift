import Foundation

final class UnkeyedContainerDecodingNode: UnkeyedDecodingContainer {

    var codingPath: [CodingKey]

    let count: Int? = nil

    private(set) var currentIndex: Int = 0

    private var nilIndices: Set<Int>

    private var dataProvider: [DecodingDataProvider]

    var isAtEnd: Bool {
        guard nilIndices.isEmpty else {
            return false
        }
        guard dataProvider.contains(where: { !$0.isAtEnd }) else {
            return true
        }
        return false
    }

    private func currentProvider() -> DecodingDataProvider {
        while let provider = dataProvider.first {
            if provider.isAtEnd {
                dataProvider.remove(at: 0)
                continue
            }
            return provider
        }
        return .init(data: .empty)
    }

    private var nextValueIsNil: Bool {
        nilIndices.contains(currentIndex)
    }

    init(codingPath: [CodingKey], provider: [DecodingDataProvider]) throws {
        self.codingPath = codingPath
        #warning("Option to include nil values here")
        self.dataProvider = provider
//        guard !provider.isAtEnd else {
//            self.nilIndices = []
//            return
//        }
        self.nilIndices = []
//        let nilCount = try Int(from: provider)
//        self.nilIndices = Set(try (0..<nilCount).map { _ in try Int(from: provider) })
    }

    private func didDecodeValue() {
        nilIndices.remove(currentIndex)
        currentIndex += 1
    }

    func decodeNil() throws -> Bool {
        guard nextValueIsNil else {
            return false
        }
        didDecodeValue()
        return true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let provider = currentProvider()
        switch type {
        case let Primitive as BinaryDecodable.Type:
            let value = try Primitive.init(includingLengthFrom: provider)
            didDecodeValue()
            return value as! T
        default:
            let provider = nextValueIsNil ? DecodingDataProvider(data: .empty) : provider
            let decoder = TopLevelDecodingContainer(codingPath: codingPath, userInfo: [:], provider: provider)
            let value = try type.init(from: decoder)
            didDecodeValue()
            return value
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }


}
