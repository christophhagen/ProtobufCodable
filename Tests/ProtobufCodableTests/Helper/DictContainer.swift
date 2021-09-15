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
    
}

extension DictContainer: ProtobufComparable {
    
    var protobuf: PB_DictContainer {
        .with {
            $0.stringDict = stringDict
            $0.uintDict = uintDict.mapValues { $0.protobuf }
            $0.intDict = .init(uniqueKeysWithValues: intDict.map { key, value in
                (Int64(key), value.protobuf)
            })
        }
    }
}
