import SwiftUI

extension AttributedString {

    private static let defaultAttributes: AttributeContainer = {
        var c = AttributeContainer()
        c.font = Font.system(.body)
        return c
    }()

    init?(mastodonHTML input: String) {
        let html = input.removingHTMLEscaping
        
        guard !html.isEmpty else {
            self.init()
            return
        }

        self.init()

        /// Stores the `AttributedString` attributes that apply to the current text fragment.
        var currentAttributes = Self.defaultAttributes

        /// Stores the partial contents of the current text fragment, gets reset when
        /// parsing of the current fragment is finished.
        var accumulator = [String]()

        /// Stores all pieces of formatted content created by parsing the HTML,
        /// which are then joined at the end to produce the final attributed string.
        var fragments = [AttributedString]()

        /// There are some text fragments that are indicated to be hidden by
        /// classes in the HTML tags. This flag is used to skip adding those fragments
        /// to the overall attributed string, effectivelly hiding them.
        var skipTextFragment = false

        /// There's an `ellipsis` class included in tags for fragments
        /// that should have an ellipsis added at the end, indicating they've been truncated for brevity.
        var addEllipsis = false

        /// The `Scanner` type is used to scan a string by looking for specific
        /// character sequences, which works great for the limited subset of HTML we want to parse.
        let scanner = Scanner(string: html)

        while !scanner.isAtEnd {
            /// Start out by looking for the first opening tag, which for Mastodon
            /// posts will always be a `<p>` (although we don't check for that here).
            guard scanner.scanString("<") != nil else { break }

            var currentTagName: String?

            /// Figure out the name of the tag by scanning up to a whitespace, a newline, or a `>` character.
            /// Checking for whitespace and newline ensures tags with attributes will have their names parsed correctly.
            /// Checking for the `>` character handles tags without any attributes.
            if let tagName = scanner.scanUpToCharacters(from: .tagNameTail) {
                /// Store the name of the tag we're currently parsing, removing any leading `/`,
                /// which will be present if this is a closing tag.
                currentTagName = tagName.replacingOccurrences(of: "/", with: "")

                if tagName.hasPrefix("/") || tagName.hasSuffix("/") {
                    /// Reset attributes corresponding to each tag type when the tag is closed.
                    if currentTagName == "a" {
                        currentAttributes.link = nil
                    } else if currentTagName == "span" {
                        currentAttributes.font = Self.defaultAttributes.font
                        accumulator.appendWhitespace()
                    } else if currentTagName == "p" {
                        /// Ideally, paragraph tags should create a paragraph break in the attributed string,
                        /// and then we would control the spacing using a paragaph style.
                        /// However, I couldn't figure out a way to do that with `AttributedString`,
                        /// so for now it just appends a double line break, which looks fine with the regular
                        /// body font style on macOS.
                        accumulator.append("\n\n")
                    } else if currentTagName == "br" {
                        /// I've only seen br tags being represented as `<br>` on Mastodon's API.
                        /// However, it's not uncommon for br tags to show up as `<br/>` in HTML,
                        /// so I'm handling that case here, call it future-proofing.
                        accumulator.append("\n")
                    }
                } else {
                    /// This handles the most common presentation of a br tag, and the only one I've
                    /// seen in Mastodon's API, which is a simple `<br>`.
                    if currentTagName == "br" {
                        accumulator.append("\n")
                    }
                }
            }

            /// Dictionary storing HTML tag attributes and their corresponding values.
            var tagAttributes = [String: String]()

            /// Scan within the tag itself by looking for the `>` character.
            /// This will give us a string with everything between the end of the tag name
            /// and the `>` character (ex: ` href="https://apple.com" rel="nofollow"`).
            if let tagContent = scanner.scanUpToString(">") {
                /// Figure out the tag's attributes using a custom regex.
                for match in tagContent.matches(of: HTMLAttributesRegex.tagAttributes) {
                    tagAttributes[String(match.1)] = String(match.2)
                }
            }

            _ = scanner.scanCharacter()

            skipTextFragment = false
            addEllipsis = false

            if currentTagName == "a" {
                /// Set the link from the tag as the link attribute for the current attributed string fragment.
                if let href = tagAttributes["href"], let url = URL(string: href) {
                    currentAttributes.link = url
                }
            } else if currentTagName == "span", let classes = tagAttributes["class"] {
                /// There are some classes Mastodon applies to the `<span>` tag
                /// that we should pay attention to, such as `invisible` and `ellipsis`.
                if classes.contains("h-card") {
                    currentAttributes.font = currentAttributes.font?.weight(.semibold)
                }
                /// If the span has the `invisible` attribute,
                /// then the text should not be included in the output.
                /// This is done later based on the `skipTextFragment` flag set here.
                if classes.contains("invisible") {
                    skipTextFragment = true
                }

                /// If the span has the `ellipsis` attribute,
                /// then the text should end with an ellipsis (…).
                /// This is done later based on the `addEllipsis` flag set here.
                if classes.contains("ellipsis") {
                    addEllipsis = true
                }
            }

            /// Find all text contained within the current tag.
            if let textContent = scanner.scanUpToCharacters(from: .lessThanGreaterThan) {
                let processedContent = textContent
                    .replacingHTMLEntities
                    + (addEllipsis ? "…" : "")

                /// Append the tag's inner text to the accumulator.
                /// The text will be appended to the output with the current attributes
                /// at the end of the current iteration.

                /// Hidden text fragments are not added to the accumulator,
                /// but are included in the plain text representation.
                if !skipTextFragment {
                    accumulator.append(processedContent)
                }
            }

            /// Join all contents in the accumulator as a plain string.
            let plainText = accumulator.joinedTextFragments()

            /// Create an attributed fragment with the plain string.
            var fragment = AttributedString(plainText)

            /// Set an alternate description, which can be used as a plain text representation
            /// for customizing things like VoiceOver, for example.
            fragment.alternateDescription = plainText

            /// Apply current attributes to the fragment.
            fragment.mergeAttributes(currentAttributes)

            /// Append the fragment to the array which is later merged into the final attributed string.
            fragments.append(fragment)

            accumulator.removeAll(keepingCapacity: true)
        }

        /// Merge all fragments into the final attributed string.
        for (index, fragment) in fragments.enumerated() {
            /// Ignore the last fragment if it's empty or only comprised of whitespaces and newlines.
            if index == fragments.count - 1 {
                guard !fragment.isEmptyFragment else { continue }
            }

            append(fragment)
        }
    }

}

// MARK: - HTML Entities / Escaping

private extension CharacterSet {
    /// Characters that finish the declaration of an HTML tag's name.
    static let         tagNameTail = CharacterSet(charactersIn: " >\n")
    /// The `<` and `>` characters.
    static let lessThanGreaterThan = CharacterSet.init(charactersIn: "<>")
}

private extension String {
    var removingHTMLEscaping: String {
        replacingOccurrences(of: "\\u003c", with: "<")
            .replacingOccurrences(of: "\\u003e", with: ">")
    }
}

private typealias HTMLAttributesRegex = Regex<(Substring, Substring, Substring)>

private extension HTMLAttributesRegex {
    /// Straightforward regex to find attribute names and their corresponding values.
    /// This looks for some text separated by an equal sign and some more text in quotes.
    ///
    /// This is definitely fragile and not something a web browser would be able to use,
    /// but for the very limited HTML syntax that's allowed by Mastodon for posts,
    /// this works well enough.
    static let tagAttributes: Self = {
        try! Regex(#"([a-zA-Z]{1,})\="([^"]{1,})"#)
    }()
}

private extension String {
    var replacingHTMLEntities: String {
        var output = self

        for (entity, replacement) in Self.HTMLEntities {
            output = output.replacingOccurrences(of: entity, with: replacement)
        }

        return output
    }

    /// Source: https://www.freeformatter.com/html-entities.html
    static let HTMLEntities: [String: String] = [
        "&#32;": " ",
        "&#33;": "!",
        "&#34;": "\"",
        "&#35;": "#",
        "&#36;": "$",
        "&#37;": "%",
        "&#38;": "&",
        "&amp;": "&",
        "&#39;": "'",
        "&#40;": "(",
        "&#41;": ")",
        "&#42;": "*",
        "&#43;": "+",
        "&#44;": ",",
        "&#45;": "-",
        "&#46;": ".",
        "&#47;": "/",
        "&#48;": "0",
        "&#49;": "1",
        "&#50;": "2",
        "&#51;": "3",
        "&#52;": "4",
        "&#53;": "5",
        "&#54;": "6",
        "&#55;": "7",
        "&#56;": "8",
        "&#57;": "9",
        "&#58;": ":",
        "&#59;": ";",
        "&#60;": "<",
        "&lt;": "<",
        "&#61;": "=",
        "&#62;": ">",
        "&gt;": ">",
        "&#63;": "?",
        "&#64;": "@",
        "&#65;": "A",
        "&#66;": "B",
        "&#67;": "C",
        "&#68;": "D",
        "&#69;": "E",
        "&#70;": "F",
        "&#71;": "G",
        "&#72;": "H",
        "&#73;": "I",
        "&#74;": "J",
        "&#75;": "K",
        "&#76;": "L",
        "&#77;": "M",
        "&#78;": "N",
        "&#79;": "O",
        "&#80;": "P",
        "&#81;": "Q",
        "&#82;": "R",
        "&#83;": "S",
        "&#84;": "T",
        "&#85;": "U",
        "&#86;": "V",
        "&#87;": "W",
        "&#88;": "X",
        "&#89;": "Y",
        "&#90;": "Z",
        "&#91;": "[",
        "&#92;": "\\",
        "&#93;": "]",
        "&#94;": "^",
        "&#95;": "_",
        "&#96;": "`",
        "&#97;": "a",
        "&#98;": "b",
        "&#99;": "c",
        "&#100;": "d",
        "&#101;": "e",
        "&#102;": "f",
        "&#103;": "g",
        "&#104;": "h",
        "&#105;": "i",
        "&#106;": "j",
        "&#107;": "k",
        "&#108;": "l",
        "&#109;": "m",
        "&#110;": "n",
        "&#111;": "o",
        "&#112;": "p",
        "&#113;": "q",
        "&#114;": "r",
        "&#115;": "s",
        "&#116;": "t",
        "&#117;": "u",
        "&#118;": "v",
        "&#119;": "w",
        "&#120;": "x",
        "&#121;": "y",
        "&#122;": "z",
        "&#123;": "{",
        "&#124;": "|",
        "&#125;": "}",
        "&#126;": "~",
    ]
}

private extension Array where Element == String {
    /// Appends a whitespace to the array, unless the last element is already a whitespace.
    mutating func appendWhitespace() {
        guard last != " " else { return }
        append(" ")
    }

    /// Joins all text fragments, separating them by a single whitespace
    /// and ensuring there aren't any double spaces or newlines that begin with a space.
    func joinedTextFragments() -> Element {
        map { $0.trimmingPrefix(while: { $0 == " " }) }
            .joined(separator: " ")
    }
}

private extension AttributedString {
    /// Whether this attributed string is completely empty or comprised of only whitespaces and/or newline characters.
    var isEmptyFragment: Bool {
        guard let alternateDescription = self.alternateDescription else { return true }
        return alternateDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
}

#if DEBUG
extension AttributedString {
    static let mastodonPostPreviews: [AttributedString] = {
        [
            AttributedString(mastodonHTML: "<p>Got one more podcast to share with you before the holidays 😀</p><p>On the latest episode of Stacktrace, <span class=\"h-card\"><a href=\"https://mastodon.social/@_inside\" class=\"u-url mention\">@<span>_inside</span></a></span> and I talk about building computers, running A/B tests as an indie dev, using UIKit as a layout tool for SwiftUI views, and picking between different data storage solutions.</p><p>Hope you&#39;ll enjoy the episode 👍</p><p><a href=\"https://stacktracepodcast.fm/episodes/192\" target=\"_blank\" rel=\"nofollow noopener noreferrer\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">stacktracepodcast.fm/episodes/</span><span class=\"invisible\">192</span></a></p>")!,
            AttributedString(mastodonHTML: "<p>After Yang is definitely one of my top 5 movies for the year. If you enjoy slower-paced sci-fi movies, I strongly recommend it — it’s only 90 minutes! <a href=\"https://www.theverge.com/2022/12/23/23516723/after-yang-sci-fi-design-interview-alexandra-schaller\" target=\"_blank\" rel=\"nofollow noopener noreferrer\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">theverge.com/2022/12/23/235167</span><span class=\"invisible\">23/after-yang-sci-fi-design-interview-alexandra-schaller</span></a></p>")!,
            AttributedString(mastodonHTML: "<p>An interview with Mastodon CEO Eugen Rochko on scaling the network, plans for a Mozilla-like split revenue model, shunning ads, talking to investors, and more (Ingrid Lunden/TechCrunch)</p><p><a href=\"https://techcrunch.com/2022/12/23/how-mastodon-is-scaling-amid-the-twitter-exodus/\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">techcrunch.com/2022/12/23/how-</span><span class=\"invisible\">mastodon-is-scaling-amid-the-twitter-exodus/</span></a><br><a href=\"http://www.techmeme.com/221223/p12#a221223p12\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">http://www.</span><span class=\"ellipsis\">techmeme.com/221223/p12#a22122</span><span class=\"invisible\">3p12</span></a></p>")!,
        ]
    }()

}

struct AttributedStringMastodonHTML_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ForEach(AttributedString.mastodonPostPreviews.indices, id: \.self) { i in
                let content = AttributedString.mastodonPostPreviews[i]
                Text(content)
                    .lineSpacing(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.background)
            }
        }
        .padding()
        .frame(maxWidth: 420, minHeight: 600, alignment: .leading)
    }
}
#endif
