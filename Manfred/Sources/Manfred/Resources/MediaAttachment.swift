import Foundation

public struct MediaAttachment: Equatable, Identifiable, Codable {
    public enum MediaType: String, Codable {
        case image
        case gifv
        case video
        case audio
        case unknown
    }

    public let id: String
    public let type: MediaType
    public let url: URL
    public let previewUrl: URL?
    public let description: String?
    public let blurhash: String?

    public init(id: String, type: MediaAttachment.MediaType, url: URL, previewUrl: URL, description: String? = nil, blurhash: String? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.previewUrl = previewUrl
        self.description = description
        self.blurhash = blurhash
    }
}
