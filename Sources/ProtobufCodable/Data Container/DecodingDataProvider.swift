//
//  File.swift
//  
//
//  Created by iMac on 14.09.21.
//

import Foundation

public final class DecodingDataProvider {

    private let data: [UInt8]

    private var processedBytes: Int = 0

    init(data: Data) {
        self.data = data.bytes
    }

    var remainingByteCount: Int {
        data.count - processedBytes
    }

    func getNextBytes(_ count: Int) throws -> Data {
        guard count <= remainingByteCount else {
            fatalError()
            throw ProtobufDecodingError.missingData
        }
        let newCount = processedBytes + count
        defer { processedBytes = newCount }
        return Data(data[processedBytes..<newCount])
    }

    func getNextByte() throws -> UInt8 {
        try getNextBytes(1).first!
    }

    func getRemainingBytes() -> Data {
        defer { processedBytes = data.count }
        return Data(data[processedBytes...])
    }

    var isAtEnd: Bool {
        remainingByteCount == 0
    }

    func extractVarint() throws -> Data {
        for i in 0..<10 {
            let index = processedBytes + i
            guard index < data.count else {
                throw ProtobufDecodingError.missingData
            }
            guard data[index] & 0x80 > 0 else {
                defer { processedBytes = index + 1 }
                return Data(data[processedBytes...index])
            }
        }
        throw ProtobufDecodingError.invalidVarintEncoding
    }

    func getKeyedField() throws -> (Tag, Data) {
        let tag = try Tag(from: self)
        let data: Data
        // Most wire types have a fixed length
        if let length = tag.valueLength {
            data = try getNextBytes(length)
        }else if tag.wireType == .lengthDelimited {
            data = try getLengthEncodedField()
        } else {
            // Only choice left is varint
            data = try extractVarint()
        }
        return (tag, data)
    }

    func getLengthEncodedField() throws -> Data {
        let length = try Int(from: self)
        return try getNextBytes(length)
    }

    func printRemainingBytes() {
        print("Remaining: \(data[processedBytes...])")
    }

    func printAllBytes() {
        print("All: \(data)")
    }
}

extension DecodingDataProvider: CustomStringConvertible {

    public var description: String {
        "\(processedBytes)/\(data.count) bytes: \(data[processedBytes...])"
    }
}
