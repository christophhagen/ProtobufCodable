import Foundation

struct Repeated: Codable {
    
    enum CodingKeys: Int, CodingKey {
        case unsigneds = 1
        case messages = 2
        case strings = 3
    }
    
    var unsigneds: [UInt32] = []
    
    var messages: [BasicMessage] = []

    var strings: [String] = []
}

extension Repeated: ProtobufComparable {

    init(protoObject: PB_Repeated) {
        self.unsigneds = protoObject.unsigneds
        self.messages = protoObject.messages.map(BasicMessage.init)
        self.strings = protoObject.strings
    }
    
    var protobuf: PB_Repeated {
        .with {
            $0.unsigneds = unsigneds
            $0.messages = messages.map { $0.protobuf }
            $0.strings = strings
        }
    }
}

extension Repeated: CustomStringConvertible {

    var description: String {
        "Repeated:\n  \(unsigneds)\n  \(messages)"
    }
}
