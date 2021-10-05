import XCTest
@testable import ProtobufCodable
import SwiftProtobuf

final class ByteOrderTests: XCTestCase {
    
    private func roundTripHost<T>(_ type: T.Type = T.self, _ value: T) where T: HostIndependentRepresentable, T: Equatable {
        let converted = value.hostIndependentRepresentation
        let reversed = T(fromHostIndependentRepresentation: converted)
        XCTAssertEqual(value, reversed)
        
        let data = value.hostIndependentBinaryData
        do {
            let decoded = try T.init(hostIndependentBinaryData: data)
            XCTAssertEqual(value, decoded)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    private func roundTripHost<T>(_ type: T.Type = T.self, _ values: T...) where T: HostIndependentRepresentable, T: Equatable {
        values.forEach { roundTripHost(type, $0) }
    }
    
    func testUInt8() {
        roundTripHost(UInt8.self, .zero, 123, 234, .max, .min)
    }
    
    func testInt8() {
        roundTripHost(Int8.self, .zero, 123, -123, .max, .min)
    }
    
    func testUInt16() {
        roundTripHost(UInt16.self, .zero, 12345, 23456, .max, .min)
    }
    
    func testInt16() {
        roundTripHost(Int16.self, .zero, 12345, -12345, .max, .min)
    }
    
    func testUInt32() {
        roundTripHost(UInt32.self, .zero, 1234567890, 2345678901, .max, .min)
    }
    
    func testInt32() {
        roundTripHost(Int32.self, .zero, 1234567890, -1234567890, .max, .min)
    }
    
    func testUInt64() {
        roundTripHost(UInt64.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min)
    }
    
    func testInt64() {
        roundTripHost(Int64.self, .zero, 1234567890123456789, -1234567890123456789, .max, .min)
    }
    
    func testFloat() {
        roundTripHost(Float.self, .zero, 123, -123, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
    }
    
    func testDouble() {
        roundTripHost(Double.self, .zero, 123, -123, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
    }
    
}
