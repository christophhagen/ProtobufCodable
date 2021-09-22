import Foundation

struct DictContainer: Encodable {
    
    enum CodingKeys: Int, CodingKey {
        case stringDict = 1
        case uintDict = 2
        case intDict = 3
    }
    
    var stringDict: Dictionary<String,Int32> = [:]
    
    var uintDict: Dictionary<UInt32, BasicMessage> = [:]
    
    var intDict: Dictionary<Int,BasicMessage> = [:]

    var intStringDict: Dictionary<Int,String> = [:]
}

extension DictContainer: Equatable {
    
}

extension DictContainer: ProtobufComparable {

    init(protoObject: PB_DictContainer) {
        self.stringDict = protoObject.stringDict
        self.uintDict = protoObject.uintDict.mapValues(BasicMessage.init)
        self.intDict = .init(uniqueKeysWithValues: protoObject.intDict.map { key, value in
            (Int(key), BasicMessage(protoObject: value))
        })
        self.intStringDict = .init(uniqueKeysWithValues: protoObject.intStringDict.map { (Int($0), $1) })
    }
    
    var protobuf: PB_DictContainer {
        .with {
            $0.stringDict = stringDict
            $0.uintDict = uintDict.mapValues { $0.protobuf }
            $0.intDict = .init(uniqueKeysWithValues: intDict.map { key, value in
                (Int64(key), value.protobuf)
            })
            $0.intStringDict = .init(uniqueKeysWithValues: intStringDict.map { key, value in
                (Int64(key), value)
            })
        }
    }
}
