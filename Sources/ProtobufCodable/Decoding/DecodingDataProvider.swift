//
//  File.swift
//  
//
//  Created by iMac on 14.09.21.
//

import Foundation

public protocol DecodingDataProvider {
    
    func getNextBytes(_ count: Int) throws -> Data
    
    var remainingByteCount: Int { get }
}

extension DecodingDataProvider {
    
    func getNextByte() throws -> UInt8 {
        try getNextBytes(1).first!
    }
    
    func getRemainingBytes() -> Data {
        try! getNextBytes(remainingByteCount)
    }
    
    var isAtEnd: Bool {
        remainingByteCount == 0
    }
}
