//
//  YouTubeInterview.swift
//  Federal
//
//  Created by シン on 2024/06/21.
//

import Foundation
import SwiftData

@Model
final class YouTubeInterview: Equatable {
    var title: String
    var link: String
    var thumbnailLink: String
    var channelId: String
    var publishedDate: String

    init(_ item: YouTubeSearchResult.Item) {
        self.title = item.snippet.title
        self.link = item.videoURL().absoluteString
        self.thumbnailLink = item.snippet.thumbnails.default.url
        self.channelId = item.snippet.channelId
        self.publishedDate = item.snippet.publishedAt
    }
}
