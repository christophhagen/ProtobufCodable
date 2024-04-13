import Foundation

@propertyWrapper
public struct Unpacked<S> where S: Packable {

    public var wrappedValue: [S]

    public init(wrappedValue: [S]) {
        self.wrappedValue = wrappedValue
    }
}

extension Unpacked: Codable where S: Codable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for value in wrappedValue {
            try container.encode(value)
        }
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [S] = []
        while !container.isAtEnd {
            let element = try container.decode(S.self)
            elements.append(element)
        }
        self.wrappedValue = elements
    }

}

extension Unpacked: Equatable where S: Equatable {

}

extension Unpacked: EncodableContainer where S: CodablePrimitive {

    func encode(forKey key: Int) -> Data {
        wrappedValue.mapAndJoin {
            $0.encodeAlways(forKey: key)
        }
    }


    func encodeForUnkeyedContainer() throws -> Data {
        // TODO: Set correct coding path
        throw DecodingError.notSupported("Unpacked containers are not supported in unkeyed containers", codingPath: [])
    }
}
