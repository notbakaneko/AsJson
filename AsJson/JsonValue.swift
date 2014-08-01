//
//  JsonValue.swift
//  AsJson
//

import Foundation


public enum JsonValue: Equatable, Hashable {
    case JsonObject(Dictionary<String, JsonValue>)
    case JsonArray(Array<JsonValue>)
    case JsonString(String)
    case JsonNumber(NSNumber)
    case JsonBool(Bool)
    case JsonNull
    case JsonInvalid(NSError)

    init(_ rawValue: AnyObject) {
        switch rawValue {
        case let raw as NSNull:
            self = .JsonNull

        case let raw as NSString:
            self = .JsonString(raw)

        case let raw as NSNumber:
            self = .JsonNumber(raw)

        case let raw as NSArray:
            var array = [JsonValue]()
            for item in raw {
                array += JsonValue(item)
            }
            self = .JsonArray(array)

        case let raw as NSDictionary:
            var dictionary = [String: JsonValue]()
            for (possibleKey, value) in raw {
                if let key = possibleKey as? String {
                    dictionary[key] = JsonValue(value)
                }
            }
            self = .JsonObject(dictionary)

        default:
//            FIXME: bursts into flames
//            self = .JsonInvalid(NSError(domain: "model.parser.json", code: -1, userInfo: [:]))
            self = .JsonInvalid(NSError())
        }
    }


    var string: String? {
        switch self {
        case .JsonString(let value): return value
        default: return nil
        }
    }

    var url: NSURL? {
        switch self {
        case .JsonString(let value): return NSURL(string: value)
        default: return nil
        }
    }

    var int: Int? {
        switch self {
        case .JsonNumber(let value): return value.integerValue
        case .JsonString(let value): return value.bridgeToObjectiveC().integerValue
        case .JsonBool(let value): return Int(value)
        default: return nil
        }
    }

    var bool: Bool? {
        switch self {
        case .JsonBool(let value): return value
        case .JsonNumber(let value): return value.boolValue
        default: return nil
        }
    }

    var double: Double? {
        switch self {
        case .JsonNumber(let value): return value.doubleValue
        case .JsonString(let value): return value.bridgeToObjectiveC().doubleValue
        default: return nil
        }
    }

    var array: [JsonValue]? {
        switch self {
        case .JsonArray(let value): return value
        default: return nil
        }
    }

    var object: [String : JsonValue]? {
        switch self {
        case .JsonObject(let value): return value
        default: return nil
        }
    }


    subscript(key: String) -> JsonValue? {
        switch self {
        case let .JsonObject(o):
            return o[key]

        default:
            return nil
        }
    }

    subscript(index: Int) -> JsonValue? {
        switch self {
        case let .JsonArray(a):
            return a[index]

        default:
            return nil
        }
    }

    public var hashValue: Int {
        switch self {
        case .JsonObject(let value):
            return value.count.hashValue

        case .JsonArray(let value):
            return value.count.hashValue

        case .JsonString(let value):
            return value.hashValue

        case .JsonNumber(let value):
            return value.hashValue

        case .JsonBool(let value):
            return value.hashValue

        case .JsonNull:
            return 0

        default:
            return 0
        }
    }
}

// JsonValue: Equatable
public func == (lhs: JsonValue, rhs: JsonValue) -> Bool {
    switch lhs {
    case .JsonObject(let lvalue):
        switch rhs {
        case .JsonObject(let rvalue): return rvalue == lvalue
        default: return false
        }

    case .JsonArray(let lvalue):
        switch rhs {
        case .JsonArray(let rvalue): return rvalue == lvalue
        default: return false
        }

    case .JsonString(let lvalue):
        switch rhs {
        case .JsonString(let rvalue): return rvalue == lvalue
        default: return false
        }

    case .JsonNumber(let lvalue):
        switch rhs {
        case .JsonNumber(let rvalue): return rvalue == lvalue
        default: return false
        }

    case .JsonBool(let lvalue):
        switch rhs {
        case .JsonBool(let rvalue): return rvalue == lvalue
        default: return false
        }

    case .JsonNull:
        switch rhs {
        case .JsonNull: return true
        default: return false
        }

    default:
        return false
    }
}


extension JsonValue : Printable {
    public var name: String {
    return "🐱"
    }

    public var description: String {
        switch self {
        case .JsonInvalid(let error):
            // FIXME:
            return "error"
        default:
            return printableString()
        }
    }

    func printableString(indent: String = "") -> String {
        switch self {
        case .JsonObject(let object):
            var string = ""
            for (key, value) in object {
                let valueString = value.printableString(indent: indent + "  ")
                string += "\(indent)  \(key) : \(valueString)\n"
            }
            return "{\n\(string)\(indent)}"

        case .JsonArray(let array):
            var string = ""
            for (index, value) in enumerate(array) {
                if index != array.count - 1 {
                    string += "\(value.printableString()), "
                } else {
                    string += "\(value.printableString())"
                }
            }

            return "[\(string)]"

        case .JsonString(let string):
            return "\"\(string)\""

        case .JsonNumber(let number):
            return number.description

        case .JsonBool(let bool):
            return bool.description

        case .JsonNull:
            return "(null)"

        case .JsonInvalid(let error):
            return "Invalid JSON value"
            
        default:
            return "not implemented"
        }
    }
}
