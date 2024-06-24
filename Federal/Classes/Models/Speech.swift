//
//  Speech.swift
//  Federal
//
//  Created by シン on 2024/06/20.
//

import FeedKit
import Foundation
import SwiftData
import SwiftSoup

@Model
final class Speech: Equatable {

    // Metadata from RSS
    var title: String
    var link: String
    var itemDescription: String
    var category: String
    var pubDate: Date

    // Article header
    var time: String?
    var speaker: String?
    var location: String?
    var videoLink: String?

    // Article body
    var contents: String?

    init() {
        self.title = "Unrecognized Item"
        self.link = "about:blank"
        self.itemDescription = ""
        self.category = ""
        self.pubDate = .distantPast
    }

    init(item: RSSFeedItem) {
        if let title = item.title,
           let link = item.link,
           let itemDescription = item.description,
           let categories = item.categories,
           let pubDate = item.pubDate {
            self.title = title
            self.link = link
            self.itemDescription = itemDescription
            self.category = categories.first?.value ?? ""
            self.pubDate = pubDate
        } else {
            self.title = "Unrecognized Item"
            self.link = "about:blank"
            self.itemDescription = ""
            self.category = ""
            self.pubDate = .distantPast
        }
    }

    init(title: String, link: String, itemDescription: String, category: String, pubDate: Date) {
        self.title = title
        self.link = link
        self.itemDescription = itemDescription
        self.category = category
        self.pubDate = pubDate
    }

    func articleText() async -> String? {
        if let feedItemURL = URL(string: link) {
            do {
                let (feedItemData, _) = try await URLSession.shared.data(from: feedItemURL)
                let feedItemHTML = String(data: feedItemData, encoding: .utf8)
                if let feedItemHTML,
                   let htmlDocument = try? SwiftSoup.parse(feedItemHTML),
                   let articleElement = try? htmlDocument.select("#article") {
                    if let articleHeader = try? articleElement.select(".heading").first() {
                        if let articleTitle = try? articleHeader.select(".title").first()?.text() {
                            title = articleTitle
                        }
                        if let articleTime = try? articleHeader.select(".article__time").first()?.text() {
                            time = articleTime
                        }
                        if let articleSpeaker = try? articleHeader.select(".speaker").first()?.text() {
                            speaker = articleSpeaker
                        }
                        if let articleLocation = try? articleHeader.select(".location").first()?.text() {
                            location = articleLocation
                        }
                        if let articleVideo = try? articleHeader.select(".watchLive").first()?.attr("href") {
                            videoLink = articleVideo
                        }
                    }
                    if let articleBodyCandidateElements = try? articleElement.select(".col-xs-12.col-sm-8.col-md-8"),
                       articleBodyCandidateElements.count >= 2 {
                        let articleBody = articleBodyCandidateElements[1]
                        var articleBodyText: String = ""
                        if let articleBodyElements = try? articleBody.getAllElements() {
                            for element in articleBodyElements where element.parent() == articleBody {
                                if let elementIsParagraph = try? element.iS("p"), elementIsParagraph {
                                    articleBodyText += "\(element.ownText())\n"
                                } else if let elementIsDivider = try? element.iS("hr"), elementIsDivider {
                                    break
                                }
                            }
                            return articleBodyText.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return nil
    }

    static func == (lhs: Speech, rhs: Speech) -> Bool {
        return lhs.title == rhs.title && lhs.link == rhs.link
    }
}
