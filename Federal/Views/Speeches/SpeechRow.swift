//
//  SpeechRow.swift
//  Federal
//
//  Created by シン on 2024/06/21.
//

import SwiftUI

struct SpeechRow: View {

    var feedItem: Speech

    @State var isExpanded: Bool = false

    var body: some View {
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
                if let speaker = feedItem.speaker {
                    Image(systemName: "person.fill")
                    Text(speaker)
                }
                if let location = feedItem.location {
                    Image(systemName: "location.fill")
                    Text(location)
                }
                Spacer()
                if let time = feedItem.time {
                    Image(systemName: "clock.fill")
                    Text(time)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(1, reservesSpace: true)
            if let contents = feedItem.contents {
                Text(contents)
                    .font(.body)
                    .lineLimit(isExpanded ? nil : 3)
            }
        }
        .padding([.top, .bottom], 8.0)
        .contentShape(.rect)
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
