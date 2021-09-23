import XCTest
import ProtobufCodable
import SwiftProtobuf

final class RepeatedFieldsTests: XCTestCase {
    
    func testRepeatedPrimitives() throws {
        let codable = Repeated(
            unsigneds: [0,123,234567890])
        try roundTrip(codable)
    }
    
    func testMultipleRepeatedPrimitives() throws {
        // Protobuf:
        //            1,2 LE  0, 123, 234567890
        // unsigneds: [10, 6, 0, 123, 210, 241, 236, 111]
        // messages:
        //            2,2  LE 1,1   3.14
        //   basic:   [18, 20, 9,   31, 133, 235, 81, 184, 30, 9, 64, ...
        //                  4,0    -1234567890
        //              ... 32,    174, 250, 167, 179, 251, 255, 255, 255, 255, 1
        //            2,2  LE 2,5    -3.14              11,5   -1234
        //   basic:   [18, 10, 21,   195, 245, 72, 192,   93,  46, 251, 255, 255]

        let codable = Repeated(
            unsigneds: [0,123,234567890],
            messages: [
                BasicMessage(double: 3.14, int64: -1234567890, boolean: false),
                BasicMessage(float: -3.14, signedFixedInt32: -1234)
            ])
        try roundTrip(codable)
    }

    func testDecoding() throws {
        // Codable:
        //            1,2 LE  0, 123, 234567890
        // unsigneds: [10, 6, 0, 123, 210, 241, 236, 111]

        let unsigneds = Data([10, 6, 0, 123, 210, 241, 236, 111])

        // messages:
        //            2,2   LE 1,1   3.14
        //   basic:   [18, 127, 9,   31, 133, 235, 81, 184, 30, 9, 64, ...
        //                  4,0    -1234567890
        //              ... 32,    174, 250, 167, 179, 251, 255, 255, 255, 255, 1
        //            2,2  LE 2,5    -3.14              11,5   -1234
        //   basic:   [18, 10, 21,   195, 245, 72, 192,   93,  46, 251, 255, 255]

        let message1 = Data([/* Tag: 18, */
                             /* 127, */
                             /* Len: 67, */
                             9, 31, 133, 235, 81, 184, 30, 9, 64,
                             21, 0, 0, 0, 0,
                             24, 0,
                             32, 174, 250, 167, 179, 251, 255, 255, 255, 255, 1,
                             40, 0,
                             48, 0,
                             56, 0,
                             64, 0,
                             77, 0, 0, 0, 0,
                             81, 0, 0, 0, 0, 0, 0, 0, 0,
                             93, 0, 0, 0, 0,
                             97, 0, 0, 0, 0, 0, 0, 0, 0,
                             104, 0,
                             114, 0, /* <- Length added */
                             122, 0]) /* <- Length added */
        let message2 = Data([/* Tag: 18, */
                             /* Len: 58, */
                             9, 0, 0, 0, 0, 0, 0, 0, 0,
                             21, 195, 245, 72, 192,
                             24, 0,
                             32, 0,
                             40, 0,
                             48, 0,
                             56, 0,
                             64, 0,
                             77, 0, 0, 0, 0,
                             81, 0, 0, 0, 0, 0, 0, 0, 0,
                             93, 46, 251, 255, 255,
                             97, 0, 0, 0, 0, 0, 0, 0, 0,
                             104, 0,
                             114, 0, /* <- Length added */
                             122, 0]) /* <- Length added */
        let message1Data = Data([18, UInt8(message1.count)]) + message1
        let message2Data = Data([18, UInt8(message2.count)]) + message2
        let data = unsigneds + message1Data + message2Data
        let _ = try PB_Repeated(serializedData: data)
//        var max = 0
//        for end in 1...data.count {
//            do {
//                let _ = try PB_Repeated(serializedData: data[0..<end])
//                max = end
//            } catch let error as SwiftProtobuf.BinaryDecodingError where error == .truncated {
//
//            } catch {
//                print(error)
//            }
//        }
//        print("Found max index: \(max)")
//        print(data[0..<max].bytes)
//        print(data.bytes)
    }
}
