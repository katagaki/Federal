//
//  Interviews.swift
//  Federal
//
//  Created by シン on 2024/06/21.
//

import AVKit
import SVEVideoUI
import SwiftData
import SwiftUI
import YouTubeKit

struct Interviews: View {
    @Environment(\.modelContext) private var modelContext

    var channelId: String

    @State var viewPath: [URL?] = []

    @State var isPowellMode: Bool = false

    @Query var videos: [YouTubeInterview]
    @AppStorage(wrappedValue: "", "YouTubeInterviews.NextPageToken") var nextPageToken: String

    var body: some View {
        NavigationStack(path: $viewPath) {
            Group {
                if isPowellMode {
                    List(videos
                        .filter({ $0.channelId == channelId })
                        .filter({ ($0.title.lowercased().contains("jerome") && $0.title.lowercased().contains("powell")) ||
                                  ($0.title.lowercased().contains("chair") && $0.title.lowercased().contains("powell")) })
                        .sorted(by: { $0.publishedDate > $1.publishedDate }), id: \.publishedDate) { item in
                        InterviewRow(viewPath: $viewPath, item: item)
                    }
                } else {
                    List(videos
                        .filter({ $0.channelId == channelId })
                        .sorted(by: { $0.publishedDate > $1.publishedDate }), id: \.publishedDate) { item in
                        InterviewRow(viewPath: $viewPath, item: item)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Toggle("Powell Mode", isOn: $isPowellMode)
                        if nextPageToken != "" {
                            Button("Get Next Page") {
                                Task {
                                    await getFromAPI(nextPageToken: nextPageToken)
                                }
                            }
                        }
                        Button("Get From API") {
                            Task {
                                await getFromAPI()
                            }
                        }
                        Button("Delete All", role: .destructive) {
                            for video in videos where video.channelId == channelId {
                                modelContext.delete(video)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: URL?.self) { url in
                VStack {
                    if let url {
                        Video(url: url)
                            .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                    }
                }
            }
        }
    }

    func getFromAPI(nextPageToken: String? = nil) async {
        // Generate URLRequest
        let apiKey = "AIzaSyAoVFilY1Ng9AM17Wjg3kz6m6rfKN3UGsk"
        var apiURLString = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelId=\(channelId)&maxResults=50&eventType=none&order=date&q=Jerome%20Powell&type=video&videoDuration=long&key=\(apiKey)"
        if let nextPageToken {
            apiURLString += "&pageToken=\(nextPageToken)"
        }
        let apiURL = URL(string: apiURLString)!
        var request = URLRequest(url: apiURL)
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Call API and decode answer
        if let (data, _) = try? await URLSession.shared.data(for: request) {
            do {
                let decoder = JSONDecoder()
                let decodedSearchResult = try decoder.decode(YouTubeSearchResult.self, from: data)
                modelContext.autosaveEnabled = false
                for item in decodedSearchResult.items {
                    let newYouTubeInterviewItem = YouTubeInterview(item)
                    modelContext.insert(newYouTubeInterviewItem)
                }
                await MainActor.run {
                    modelContext.autosaveEnabled = true
                    try? modelContext.save()
                    self.nextPageToken = decodedSearchResult.nextPageToken ?? ""
                }
            } catch {
                debugPrint(error)
                debugPrint(error.localizedDescription)
            }
        }
    }
}
