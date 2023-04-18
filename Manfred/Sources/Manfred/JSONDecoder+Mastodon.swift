import Foundation

struct InvalidDateFormat: Error {
    let stringValue: String
}

extension JSONDecoder {
    static let mastodon: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let df = ISO8601DateFormatter()
        df.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withFractionalSeconds
        ]

        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            do {
                let stringValue = try container.decode(String.self)
                guard let date = df.date(from: stringValue) else {
                    throw InvalidDateFormat(stringValue: stringValue)
                }
                return date
            } catch {
                let intValue = try container.decode(Int.self)
                return Date(timeIntervalSinceReferenceDate: TimeInterval(intValue))
            }
        })

        return decoder
    }()
}
