//
//  File.swift
//  
//
//  Created by CH on 16.09.21.
//

import Foundation

struct Tag: ByteDecodable {

    let wireType: WireType

    let field: Int

    init(type: WireType, field: Int) {
        self.wireType = type
        self.field = field
    }

    init(from byteProvider: DecodingDataProvider) throws {
        let value = try Int(from: byteProvider)
        self.field = value >> 3
        self.wireType = WireType(rawValue: value & 0x7)!
    }

    var data: Data {
        let typeAndTag = (field << 3) | wireType.rawValue
        return typeAndTag.binaryData()
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
