//
//  YouTubeDownloader.swift
//  Federal
//
//  Created by シン on 2024/06/26.
//

import SwiftUI
import YouTubeKit

struct YouTubeDownloader: View {

    @State var videoURL: String = ""
    @State var downloadManager: DownloadManager = DownloadManager()

    var body: some View {
        List {
            HStack {
                Group {
                    TextField("Video URL", text: $videoURL)
                        .textFieldStyle(.roundedBorder)
                    Button("Download") {
                        Task.detached {
                            await downloadManager.downloadVideo(URL(string: videoURL)!)
                        }
                    }
                }
                .disabled(downloadManager.isDownloading)
            }
            if downloadManager.isDownloading {
                HStack {
                    ProgressView(value: downloadManager.progress, total: 1.0)
                    Text(downloadManager.progress, format: .percent.precision(.fractionLength(1)))
                        .frame(width: 48.0, alignment: .leading)
                }
            }
            if let errorText = downloadManager.lastError {
                Text(errorText)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
            if downloadManager.lastDownloadCompleted {
                Text("Download completed successfully")
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    YouTubeDownloader()
}
