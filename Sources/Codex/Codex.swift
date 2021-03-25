//
//  Codex.swift
//  Codex
//
//  Created by incetro on 11/30/20.
//

import Foundation

// MARK: - Encoder

public extension Encoder {

    /// Encode a singular value into this encoder.
    func encodeSingleValue<T: Encodable>(_ value: T) throws {
        var container = singleValueContainer()
        try container.encode(value)
    }

    /// Encode a value for a given key, specified as a string.
    func encode<T: Encodable>(_ value: T, for key: String) throws {
        try encode(value, for: AnyCodingKey(key))
    }

    /// Encode a value for a given key, specified as a `CodingKey`.
    func encode<T: Encodable, K: CodingKey>(_ value: T, for key: K) throws {
        var container = self.container(keyedBy: K.self)
        try container.encode(value, forKey: key)
    }

    /// Encode a date for a given key (specified as a string), using a specific formatter.
    /// To encode a date without using a specific formatter, simply encode it like any other value.
    func encode<F: AnyDateFormatter>(_ date: Date, for key: String, using formatter: F) throws {
        try encode(date, for: AnyCodingKey(key), using: formatter)
    }

    /// Encode a date for a given key (specified using a `CodingKey`), using a specific formatter.
    /// To encode a date without using a specific formatter, simply encode it like any other value.
    func encode<K: CodingKey, F: AnyDateFormatter>(_ date: Date, for key: K, using formatter: F) throws {
        let string = formatter.string(from: date)
        try encode(string, for: key)
    }

    /// Encode a date for a given key (specified as a string), using a specific formatter.
    /// To encode a date without using a specific formatter, simply encode it like any other value.
    func encode<T: Transformer>(_ value: T.Object, for key: String, transformedBy transformer: T) throws {
        try encode(value, for: AnyCodingKey(key), transformedBy: transformer)
    }

    /// Encode a date for a given key (specified using a `CodingKey`), using a specific formatter.
    /// To encode a date without using a specific formatter, simply encode it like any other value.
    func encode<K: CodingKey, T: Transformer>(_ value: T.Object, for key: K, transformedBy transformer: T) throws {
        if let string = transformer.transform(object: value) {
            try encode(string, for: key)
        }
    }
}

// MARK: - Data

public extension Data {

    /// Decode this data into a value, optionally using a specific decoder.
    /// If no explicit encoder is passed, then the data is decoded as JSON.
    func decoded<T: Decodable>(as type: T.Type = T.self, using decoder: AnyDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}

// MARK: - Decoder

public extension Decoder {

    /// Decode a singular value from the underlying data.
    func decodeSingleValue<T: Decodable>(as type: T.Type = T.self) throws -> T {
        let container = try singleValueContainer()
        return try container.decode(type)
    }

    /// Decode a value for a given key, specified as a string.
    func decode<T: Decodable>(_ key: String, as type: T.Type = T.self) throws -> T {
        try decode(AnyCodingKey(key), as: type)
    }

    /// Decode a value for a given key, specified as a `CodingKey`.
    func decode<T: Decodable, K: CodingKey>(_ key: K, as type: T.Type = T.self) throws -> T {
        let container = try self.container(keyedBy: K.self)
        return try container.decode(type, forKey: key)
    }

    /// Decode an optional value for a given key, specified as a string. Throws an error if the
    /// specified key exists but is not able to be decoded as the inferred type.
    func decodeIfPresent<T: Decodable>(_ key: String, as type: T.Type = T.self) throws -> T? {
        try decodeIfPresent(AnyCodingKey(key), as: type)
    }

    /// Decode an optional value for a given key, specified as a `CodingKey`. Throws an error if the
    /// specified key exists but is not able to be decoded as the inferred type.
    func decodeIfPresent<T: Decodable, K: CodingKey>(_ key: K, as type: T.Type = T.self) throws -> T? {
        let container = try self.container(keyedBy: K.self)
        return try container.decodeIfPresent(type, forKey: key)
    }

    func decode<T: Transformer>(_ key: String, transformedBy transformer: T) throws -> T.Object {
        try decode(AnyCodingKey(key), transformedBy: transformer)
    }

    func decode<K: CodingKey, T: Transformer>(_ key: K, transformedBy transformer: T) throws -> T.Object {
        let container = try self.container(keyedBy: K.self)
        let rawString = try container.decode(T.JSON.self, forKey: key)
        guard let date = transformer.transform(json: rawString) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: container,
                debugDescription: "Unable to transform date string"
            )
        }
        return date
    }

    /// Decode a date from a string for a given key (specified as a string), using a
    /// specific formatter. To decode a date using the decoder's default settings,
    /// simply decode it like any other value instead of using this method.
    func decode<F: AnyDateFormatter>(_ key: String, using formatter: F) throws -> Date {
        try decode(AnyCodingKey(key), using: formatter)
    }

    /// Decode a date from a string for a given key (specified as a `CodingKey`), using
    /// a specific formatter. To decode a date using the decoder's default settings,
    /// simply decode it like any other value instead of using this method.
    func decode<K: CodingKey, F: AnyDateFormatter>(_ key: K, using formatter: F) throws -> Date {
        let container = try self.container(keyedBy: K.self)
        let rawString = try container.decode(String.self, forKey: key)
        guard let date = formatter.date(from: rawString) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: container,
                debugDescription: "Unable to format date string"
            )
        }
        return date
    }

    /// Decode a nested value for array of keys, specified as a `CodingKey`.
    /// Throws an error if keys array is empty
    func decode<T: Decodable>(_ keys: [CodingKey], as type: T.Type = T.self) throws -> T {

        guard !keys.isEmpty else {
            throw CodexDecodingError.emptyCodingKey
        }

        let keys = keys.map { AnyCodingKey($0.stringValue) }

        var container = try self.container(keyedBy: AnyCodingKey.self)
        for key in keys.dropLast() {
            container = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        }

        return try container.decode(type, forKey: keys.last!)
    }

    /// Decode a nested value for array of keys, specified as a string.
    /// Throws an error if keys array is empty
    func decode<T: Decodable>(_ keys: [String], as type: T.Type = T.self) throws -> T {
        try decode(keys.map(AnyCodingKey.init))
    }

    /// Decode a nested value for array of keys, specified as a string.
    /// Throws an error if keys array is empty
    func decode<T: Decodable>(nestedBy keys: String, separator: String = ".", as type: T.Type = T.self) throws -> T {
        try decode(keys.components(separatedBy: separator).map(AnyCodingKey.init))
    }

    /// Decode a value for a given key, specified as a string with default value.
    func decode<T: Decodable>(_ key: String, as type: T.Type = T.self, defaultValue: T) throws -> T {
        try decode(AnyCodingKey(key), as: type, defaultValue: defaultValue)
    }

    /// Decode a value for a given key, specified as a `CodingKey` with a default value.
    func decode<T: Decodable, K: CodingKey>(_ key: K, as type: T.Type = T.self, defaultValue: T) throws -> T {
        let container = try self.container(keyedBy: K.self)
        return try container.decodeWrapper(key: key, defaultValue: defaultValue)
    }
}

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    func decodeWrapper<T>(key: K, defaultValue: T) throws -> T where T : Decodable {
        try decodeIfPresent(T.self, forKey: key) ?? defaultValue
    }
}

// MARK: - AnyCodingKey

private struct AnyCodingKey: CodingKey {

    // MARK: - Properties

    let stringValue: String
    let intValue: Int?

    // MARK: - Initializers

    init(_ string: String) {
        stringValue = string
        intValue = nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

// MARK: - CodexDecodingError

public enum CodexDecodingError: Error, LocalizedError {

    case emptyCodingKey

    public var errorDescription: String? {
        switch self {
        case .emptyCodingKey:
            return "Coding keys array was empty"
        }
    }
}
