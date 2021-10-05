import Foundation
import SwiftProtobuf
import ProtobufCodable
import XCTest

protocol ProtobufComparable: Codable, Equatable {
    
    associatedtype ProtobufType: SwiftProtobuf.Message, Equatable
    
    var protobuf: ProtobufType { get }
    
    init()

    init(protoObject: ProtobufType)
}

extension ProtobufComparable {
    
    /**
     Compare an instance to its protobuf equivalent.
     - Parameter object: The protobuf object to compare.
     - Returns: `true`, if the protobuf representation is equal to the provided object.
     */
    func isEqual(to object: ProtobufType) -> Bool {
        protobuf == object
    }
}
