//
//  InterviewRow.swift
//  Federal
//
//  Created by シン on 2024/06/21.
//

import SwiftUI
import YouTubeKit

struct InterviewRow: View {

    @Binding var viewPath: [URL?]

    var item: YouTubeInterview

    @State var isDownloading: Bool = false

    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: URL(string: item.thumbnailLink)!)
            VStack(alignment: .leading) {
                HStack {
                    Text(item.title)
                }
                .fontWeight(.bold)
                .font(.subheadline)
                HStack {
                    Image(systemName: "calendar")
                    Text(item.publishedDate)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Button("Watch Video") {
                    Task {
                        let video = YouTube(url: URL(string: item.link)!, methods: [.remote, .local])
                        let streams = try await video.streams
                        let stream = streams
                            .filterVideoAndAudio()
                            .filter { $0.isNativelyPlayable }
                            .highestResolutionStream()
                        viewPath.append(stream?.url)
                    }
                }
                .buttonStyle(.link)
                Button("Download Video") {
                    isDownloading = true
                    Task {
                        let video = YouTube(url: URL(string: item.link)!, methods: [.remote, .local])
                        let streams = try await video.streams
                        let stream = streams
                            .filterVideoAndAudio()
                            .filter { $0.isNativelyPlayable }
                            .highestResolutionStream()
                        if let streamURL = stream?.url, let fileExtension = stream?.fileExtension {
                            let downloadsURL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                            let destinationURL = downloadsURL
                                .appendingPathComponent(item.title.replacing("/", with: "_"))
                                .appendingPathExtension(fileExtension.rawValue)
                            if FileManager().fileExists(atPath: destinationURL.path) {
                                debugPrint("File already exists: \(destinationURL.path)")
                            } else {
                                print("Downloading")
                                if let (temporaryFileURL, _) = try? await URLSession.shared.download(from: streamURL) {
                                    print("Download completed")
                                    try! FileManager.default.moveItem(at: temporaryFileURL, to: destinationURL)
                                }
                            }
                        }
                        isDownloading = false
                    }
                }
                .buttonStyle(.link)
                Link("Open Video", destination: URL(string: item.link)!)
            }
            .fontWeight(.bold)
            .font(.subheadline)
        }
        .overlay {
            if isDownloading {
                ZStack(alignment: .center) {
                    Color.clear
                        .background(Material.ultraThin)
                    HStack(spacing: 8.0) {
                        ProgressView()
                        Text("Downloading...")
                    }
                }
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
