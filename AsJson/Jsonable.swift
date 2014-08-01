//
//  Jsonable.swift
//  AsJson
//

import Foundation


public protocol Jsonable {
    init(jsonValue: JsonValue)
    func fromJson(jsonValue: JsonValue)
    func toJson()
}
