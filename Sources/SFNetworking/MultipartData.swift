//
//  MultipartData.swift
//  SFNetworking
//
//  Created by Tsvetan Raykov on 20.01.2026.
//
import Foundation

public struct MultipartData {
    public var fieldName: String
    public var fileName: String
    public var contentType: String
    public var data: Data
    public var fields: [String: String]

    public init(fieldName: String, fileName: String, contentType: String, data: Data, fields: [String : String]) {
        self.fieldName = fieldName
        self.fileName = fileName
        self.contentType = contentType
        self.data = data
        self.fields = fields
    }
}
