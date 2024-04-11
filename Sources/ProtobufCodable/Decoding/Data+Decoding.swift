import Foundation

typealias DataField = (type: WireType, data: Data)

extension Data {
    
    private func isAtEnd(at index: Index) -> Bool {
        index >= endIndex
    }
    
    private func nextByte(at index: inout Index) -> UInt8? {
        guard index < endIndex else {
            return nil
        }
        defer { index += 1 }
        return self[index]
    }
    
    private func nextBytes(_ count: Int, at index: inout Index) -> Data? {
        let newEndIndex = index + count
        guard newEndIndex <= endIndex else {
            return nil
        }
        defer { index = newEndIndex }
        return self[index..<newEndIndex]
    }

    /**
     Decode an unsigned integer using variable-length encoding starting at a position.
     - Returns: `Nil`, if insufficient data is available
     */
    private func decodeUInt64(at index: inout Index) -> UInt64? {
        guard let start = nextByte(at: &index) else { return nil }
        return decodeUInt64(startByte: start, at: &index)
    }

    /**
     Decode an unsigned integer using variable-length encoding starting at a position.
     */
    private func decodeUInt64(startByte: UInt8, at index: inout Index) -> UInt64? {
        guard startByte & 0x80 > 0 else {
            return UInt64(startByte)
        }

        var result = UInt64(startByte & 0x7F)
        // There are always 7 usable bits per byte, for 8 bytes
        for byteIndex in 1..<8 {
            guard let nextByte = nextByte(at: &index) else { return nil }
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << (byteIndex*7)
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                return result
            }
        }

        // The 9th byte has no next-byte bit, so all 8 bits are used
        guard let nextByte = nextByte(at: &index) else { return nil }
        result += UInt64(nextByte) << 56
        return result
    }

    func decodeNextElement(of type: WireType, at index: inout Index) throws -> Data {
        switch type {
        case .varInt:
            return try variableLengthInteger(at: &index)
        case .i64:
            return try nextBytes(8, at: &index).unwrap(orThrow: CorruptedDataError(prematureEndofDataDecoding: "field"))
        case .len:
            return try variableLengthData(at: &index)
        case .i32:
            return try nextBytes(4, at: &index).unwrap(orThrow: CorruptedDataError(prematureEndofDataDecoding: "field"))
        }
    }

    private func variableLengthData(at index: inout Index) throws -> Data {
        // Remove the nil indicator bit
        guard let length = decodeUInt64(at: &index) else {
            throw CorruptedDataError(prematureEndofDataDecoding: "field length")
        }
        guard let element = nextBytes(Int(length), at: &index) else {
            throw CorruptedDataError(prematureEndofDataDecoding: "field")
        }
        return element
    }

    private func variableLengthInteger(at index: inout Index) throws -> Data {
        var result = Data()
        for _ in 0..<10 {
            guard let next = nextByte(at: &index) else {
                throw CorruptedDataError(prematureEndofDataDecoding: "variable-length integer")
            }
            result += [next]
            if next & 0x80 == 0 {
                break
            }
        }
        return result
    }

    func decodeUnkeyedElements(of type: WireType) throws -> [Data?] {
        var elements = [Data?]()
        var index = startIndex
        while !isAtEnd(at: index) {
            let element = try decodeNextElement(of: type, at: &index)
            elements.append(element)
        }
        return elements
    }

    private func decodeNextKey(at index: inout Index) throws -> (key: Int, wireType: WireType) {
        // First, decode the next key
        guard let wireTypeAndKey = decodeUInt64(at: &index) else {
            throw CorruptedDataError(prematureEndofDataDecoding: "tag")
        }
        let rawDataType = Int(wireTypeAndKey & 0x07)
        guard let wireType = WireType(rawValue: rawDataType) else {
            throw CorruptedDataError(outOfRange: rawDataType, forType: "data type")
        }
        let key = Int(wireTypeAndKey >> 3)
        return (key, wireType)
    }

    func decodeKeyDataPairs() throws -> [Int : [DataField]] {
        var elements = [Int : [DataField]]()
        var index = startIndex
        while !isAtEnd(at: index) {
            let (key, type) = try decodeNextKey(at: &index)
            guard !isAtEnd(at: index) else {
                throw CorruptedDataError(prematureEndofDataDecoding: "element after key")
            }
            let element = try decodeNextElement(of: type, at: &index)
            elements[key] = (elements[key] ?? []) + [(type: type, data: element)]
        }
        return elements
    }
}
