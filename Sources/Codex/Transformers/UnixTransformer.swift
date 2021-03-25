//
//  DateTransformer.swift
//  Codex
//
//  Created by incetro on 3/25/21.
//

import Foundation

// MARK: - UnixTransformer

public struct UnixTransformer: Transformer {

    // MARK: - Aliases

    public typealias Object = Date
    public typealias JSON = Double

    // MARK: - Unit

    public enum Unit: TimeInterval {

        case seconds = 1
        case milliseconds = 1_000

        func addScale(to interval: TimeInterval) -> TimeInterval {
            interval * rawValue
        }

        func removeScale(from interval: TimeInterval) -> TimeInterval {
            interval / rawValue
        }
    }

    // MARK: - Properties

    /// Unit instance
    private let unit: Unit

    // MARK: - Initializers

    /// Default initializer
    /// - Parameter unit: unit instance
    public init(unit: Unit = .seconds) {
        self.unit = unit
    }

    // MARK: - Transformer

    /// Transforms some json to some object
    /// - Parameter json: some json value
    public func transform(json: Any) -> Date? {
        var timeInterval: TimeInterval?
        if let timeInt = json as? Double {
            timeInterval = TimeInterval(timeInt)
        }
        if let timeStr = json as? String {
            timeInterval = TimeInterval(atof(timeStr))
        }
        return timeInterval.flatMap {
            return Date(timeIntervalSince1970: unit.removeScale(from: $0))
        }
    }

    /// Tranforms some object to json value
    /// - Parameter object: some object
    public func transform(object date: Date) -> Double? {
        Double(unit.addScale(to: date.timeIntervalSince1970))
    }
}
