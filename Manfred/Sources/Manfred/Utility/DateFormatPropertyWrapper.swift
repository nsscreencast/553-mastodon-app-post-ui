import Foundation

public protocol DateStrategy {
    static func buildFormatter() -> DateFormatter
}

public struct YearMonthDay: DateStrategy {
    public static func buildFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
}

extension DateStrategy where Self == YearMonthDay {
    static var yearMonthDay: Self.Type { YearMonthDay.self }
}

fileprivate enum DateFormatterHolder {
    static var dateFormatters: [ObjectIdentifier: DateFormatter] = [:]
}

@propertyWrapper
public struct DateFormat<Strategy: DateStrategy>: Equatable, Hashable, Codable {
    public var wrappedValue: Date?
    public let strategy: Strategy.Type

    public init(wrappedValue: Date? = nil, _ strategy: Strategy.Type) {
        self.wrappedValue = wrappedValue
        self.strategy = strategy
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        strategy = Strategy.self
        if container.decodeNil() {
            wrappedValue = nil
        } else {
            let stringValue = try container.decode(String.self)
            let formatter = Self.dateFormatter(for: Strategy.self)
            wrappedValue = formatter.date(from: stringValue)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = wrappedValue {
            let formatter = Self.dateFormatter(for: Strategy.self)
            try container.encode(formatter.string(from: date))
        } else {
            try container.encodeNil()
        }
    }

    private static func dateFormatter(for strategy: Strategy.Type) -> DateFormatter {
        let key = ObjectIdentifier(self)
        if let formatter = DateFormatterHolder.dateFormatters[key] {
            return formatter
        }

        let formatter = Strategy.buildFormatter()
        DateFormatterHolder.dateFormatters[key] = formatter
        return formatter
    }

    public static func == (lhs: DateFormat, rhs: DateFormat) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
