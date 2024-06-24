//
//  PressReleases.swift
//  Federal
//
//  Created by シン on 2024/06/20.
//

import FeedKit
import SwiftData
import SwiftSoup
import SwiftUI

struct PressReleases: View {
    @Environment(\.modelContext) private var modelContext

    @State var title: String = ""
    @Query var feedItems: [PressRelease]

    @State var expandedFeedItems: [String] = []

    var body: some View {
        List(feedItems.sorted(by: {$0.pubDate > $1.pubDate}), id: \.link) { feedItem in
            VStack(alignment: .leading, spacing: 4.0) {
                HStack {
                    Text(feedItem.title)
                    Spacer()
                    Link("Open Article", destination: URL(string: feedItem.link)!)
                    if let videoLink = feedItem.videoLink {
                        Link("Open Video", destination: URL(string: videoLink)!)
                    }
                }
                .fontWeight(.bold)
                .font(.subheadline)
                .lineLimit(1, reservesSpace: true)
                HStack {
                    if let time = feedItem.time {
                        Image(systemName: "clock.fill")
                        Text(time)
                    }
                    Spacer()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1, reservesSpace: true)
                if let contents = feedItem.contents {
                    Text(contents)
                        .font(.body)
                        .lineLimit(expandedFeedItems.contains(feedItem.link) ? nil : 3)
                        .onTapGesture {
                            if expandedFeedItems.contains(feedItem.link) {
                                expandedFeedItems.removeAll(where: { $0 == feedItem.link })
                            } else {
                                expandedFeedItems.append(feedItem.link)
                            }
                        }
                }
            }
            .padding([.top, .bottom], 8.0)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button("Refresh") {
                        Task.detached {
                            await getNewFeeds()
                        }
                    }
                    Button("Delete All", role: .destructive) {
                        try? modelContext.delete(model: PressRelease.self)
                    }
                }
            }
        }
    }

    func getFromAPI() async {
        // TODO: Read from
        // https://www.federalreserve.gov/json/ne-press.json
    }

    func getNewFeeds() async {
        readFeed()
        await readContents()
    }

    func readFeed() {
        let feedURL = URL(string: "https://www.federalreserve.gov/feeds/press_all.xml")!
        let parser = FeedParser(URL: feedURL)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            switch feed {
            case let .rss(feed):
                if let items = feed.items {
                    for item in items {
                        let newFeedItem = PressRelease(item: item)
                        if !feedItems.contains(newFeedItem) {
                            modelContext.insert(newFeedItem)
                        }
                    }
                }
            default: break
            }
        case .failure(let error):
            debugPrint(error)
        }
    }

    func readContents() async {
        modelContext.autosaveEnabled = false
        for feedItem in feedItems {
            let articleText = await feedItem.articleText()
            await MainActor.run {
                feedItem.contents = articleText
            }
        }
        modelContext.autosaveEnabled = true
        try? modelContext.save()
    }
}
