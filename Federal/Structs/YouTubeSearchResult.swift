//
//  YouTubeSearchResult.swift
//  Federal
//
//  Created by シン on 2024/06/21.
//

import Foundation

struct YouTubeSearchResult: Decodable {
    var kind: String
    var etag: String
    var nextPageToken: String?
    var regionCode: String
    var pageInfo: PageInfo
    var items: [Item]

    struct PageInfo: Decodable {
        var totalResults: Int
        var resultsPerPage: Int
    }

    struct Item: Decodable {
        var kind: String
        var etag: String
        var id: ID
        var snippet: Snippet

        func videoURL() -> URL {
            URL(string: "https://www.youtube.com/watch?v=\(id.videoId)")!
        }

        struct ID: Decodable {
            var kind: String
            var videoId: String
        }

        struct Snippet: Decodable {
            var publishedAt: String
            var channelId: String
            var title: String
            var description: String
            var thumbnails: Thumbnail
            var channelTitle: String
            var liveBroadcastContent: String
            var publishTime: String
            
            struct Thumbnail: Decodable {
                var `default`: ThumbnailMetadata
                var medium: ThumbnailMetadata
                var high: ThumbnailMetadata

                struct ThumbnailMetadata: Decodable {
                    var url: String
                    var width: Int
                    var height: Int
                }
            }
        }
    }
}

