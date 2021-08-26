import XCTest
import ProtobufCodable
import SwiftProtobuf

final class ByteOrderTests: XCTestCase {
    
    private func roundTripCompare<T>(_ type: T.Type = T.self, _ value: T) where T: HostIndependentRepresentable, T: Equatable {
        let converted = value.hostIndependentRepresentation
        let reversed = T(fromHostIndependentRepresentation: converted)
        XCTAssertEqual(value, reversed)
    }
    
    private func roundTripCompare<T>(_ type: T.Type = T.self, _ values: T...) where T: HostIndependentRepresentable, T: Equatable {
        values.forEach{ roundTripCompare(type, $0) }
    }
    
    func testUInt8() {
        roundTripCompare(UInt8.self, .zero, 123, 234, .max, .min)
    }
    
    func testInt8() {
        roundTripCompare(Int8.self, .zero, 123, -123, .max, .min)
    }
    
    func testUInt16() {
        roundTripCompare(UInt16.self, .zero, 12345, 23456, .max, .min)
    }
    
    func testInt16() {
        roundTripCompare(Int16.self, .zero, 12345, -12345, .max, .min)
    }
    
    func testUInt32() {
        roundTripCompare(UInt32.self, .zero, 1234567890, 2345678901, .max, .min)
    }
    
    func testInt32() {
        roundTripCompare(Int32.self, .zero, 1234567890, -1234567890, .max, .min)
    }
    
    func testUInt64() {
        roundTripCompare(UInt64.self, .zero, 12345678901234567890, 2345678901234567890, .max, .min)
    }
    
    func testInt64() {
        roundTripCompare(Int64.self, .zero, 1234567890123456789, -1234567890123456789, .max, .min)
    }
    
    func testFloat() {
        roundTripCompare(Float.self, .zero, 123, -123, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
    }
    
    func testDouble() {
        roundTripCompare(Double.self, .zero, 123, -123, .infinity, .pi, .leastNonzeroMagnitude, .leastNormalMagnitude)
    }
    
}
