import Foundation

struct KeyValuePair<Key, Value> {

    enum CodingKeys: Int, CodingKey {
        case key = 1
        case value = 2
    }

    let key: Key

    let value: Value
}

extension KeyValuePair: Decodable where Key: Decodable, Value: Decodable {

}

extension KeyValuePair: Encodable where Key: Encodable, Value: Encodable {

}
