//
//  Speeches.swift
//  Federal
//
//  Created by シン on 2024/06/20.
//

import FeedKit
import SwiftData
import SwiftSoup
import SwiftUI

struct Speeches: View {
    @Environment(\.modelContext) private var modelContext

    @State var title: String = ""
    @Query var feedItems: [Speech]

    @State var isPowellMode: Bool = false

    var body: some View {
        Group {
            if isPowellMode {
                List(feedItems
                    .filter({ ($0.speaker ?? "").lowercased().contains("jerome") && ($0.speaker ?? "").lowercased().contains("powell") })
                    .sorted(by: {$0.pubDate > $1.pubDate}), id: \.link) { feedItem in
                    SpeechRow(feedItem: feedItem)
                }
            } else {
                List(feedItems.sorted(by: {$0.pubDate > $1.pubDate}), id: \.link) { feedItem in
                    SpeechRow(feedItem: feedItem)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Toggle("Powell Mode", isOn: $isPowellMode)
                    Button("Reload Data") {
                        Task.detached {
                            await getFromAPI()
                        }
                    }
                    Button("Export to Downloads") {
                        export()
                    }
                    Button("Delete All", role: .destructive) {
                        try? modelContext.delete(model: Speech.self)
                    }
                }
            }
        }
    }

    func getFromAPI() async {
        let apiURL = URL(string: "https://www.federalreserve.gov/json/ne-speeches.json")!
        var speechObjects: [FOMCSpeechObject] = []
        if let (data, _) = try? await URLSession.shared.data(from: apiURL) {
            do {
                let decoder = JSONDecoder()
                let decodedSpeechObjects = try decoder.decode([FOMCSpeechObject].self, from: data)
                speechObjects = decodedSpeechObjects
            } catch {
                debugPrint(error)
                debugPrint(error.localizedDescription)
            }
        }
        modelContext.autosaveEnabled = false
        try? modelContext.delete(model: Speech.self)
        for speechObject in speechObjects {
            if let title = speechObject.title, let link = speechObject.link, let date = speechObject.date {
                let newSpeechObject = Speech(title: title,
                                             link: link,
                                             itemDescription: "",
                                             category: "",
                                             pubDate: date)
                newSpeechObject.contents = await newSpeechObject.articleText()
                modelContext.insert(newSpeechObject)
            } else {
                debugPrint("Could not process speech object because it was missing a title, link, and/or date.")
            }
        }
        await MainActor.run {
            modelContext.autosaveEnabled = true
            try? modelContext.save()
        }
    }

    func getNewFeeds() async {
        readFeed()
        await readContents()
    }

    func readFeed() {
        let feedURL = URL(string: "https://www.federalreserve.gov/feeds/speeches.xml")!
        let parser = FeedParser(URL: feedURL)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            switch feed {
            case let .rss(feed):
                if let items = feed.items {
                    for item in items {
                        let newFeedItem = Speech(item: item)
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
            feedItem.contents = await feedItem.articleText()
        }
        modelContext.autosaveEnabled = true
        try? modelContext.save()
    }

    func export() {
        var exportData: [SpeechExport] = []
        var exportTargets = feedItems.map({ $0.exportStruct() })
        if isPowellMode {
            exportTargets = exportTargets
                .filter({ ($0.speaker).lowercased().contains("jerome") && ($0.speaker).lowercased().contains("powell") })
        }
        exportTargets = exportTargets.sorted(by: {$0.publicationDate > $1.publicationDate})
        exportData.append(contentsOf: exportTargets)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(exportData) {
            do {
                if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                    try data.write(to: downloadsURL.appendingPathComponent("Speeches-\(Date.now.timeIntervalSince1970).json"))
                    print("Saved JSON to Downloads folder.")
                }
            } catch {
                print("Could not save JSON: \(error)")
            }
        }
    }
}
