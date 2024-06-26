//
//  DownloadManager.swift
//  Federal
//
//  Created by シン on 2024/06/26.
//

import Foundation
import YouTubeKit

@Observable
class DownloadManager: NSObject, URLSessionDownloadDelegate {
    
    var isDownloading: Bool = false
    var progress: Float = 0.0
    var lastDownloadCompleted: Bool = false
    var lastError: String? = nil
    var saveDestinationURL: URL?

    func downloadVideo(_ url: URL) async {
        await MainActor.run {
            lastError = nil
            progress = 0.0
            isDownloading = true
        }
        do {
            let video = YouTube(url: url, methods: [.remote, .local])

            if let title = try? await video.metadata?.title {
                let streams = try await video.streams
                let stream = streams
                    .filterVideoAndAudio()
                    .filter { $0.isNativelyPlayable }
                    .highestResolutionStream()

                if let streamURL = stream?.url, let fileExtension = stream?.fileExtension {

                    let downloadsURL = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let destinationURL = downloadsURL
                        .appendingPathComponent(title.replacing("/", with: "_"))
                        .appendingPathExtension(fileExtension.rawValue)

                    if FileManager().fileExists(atPath: destinationURL.path) {
                        debugPrint("File already exists: \(destinationURL.path)")

                    } else {
                        print("Downloading")
                        saveDestinationURL = destinationURL
                        let request = URLRequest(url: streamURL)
                        let downloadTask = URLSession.shared.downloadTask(with: request)
                        downloadTask.delegate = self
                        downloadTask.resume()
                    }
                }
            }
        } catch {
            await MainActor.run {
                lastError = "\(error): \(error.localizedDescription)"
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let saveDestinationURL {
            try! FileManager.default.moveItem(at: location, to: saveDestinationURL)
            isDownloading = false
            lastDownloadCompleted = true
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            lastError = "\(error): \(error.localizedDescription)"
            isDownloading = false
        }
    }
}
