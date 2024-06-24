//
//  MainView.swift
//  Federal
//
//  Created by シン on 2024/06/20.
//

import SVEVideoUI
import SwiftUI
import SwiftData

struct MainView: View {
    @State var detailView: DetailView? = .fomcSpeeches

    var body: some View {
        NavigationSplitView {
            List(selection: $detailView) {
                Section("FOMC"){
                    NavigationLink("Speeches", value: DetailView.fomcSpeeches)
                    NavigationLink("Press Releases", value: DetailView.fomcPressReleases)
                }
                Section("YouTube") {
                    NavigationLink("CNBC", value: DetailView.youtubeCNBC)
                    NavigationLink("CNBC Television", value: DetailView.youtubeCNBCTelevision)
                    NavigationLink("60 Minutes", value: DetailView.youtubeSixtyMinutes)
                    NavigationLink("Bloomberg", value: DetailView.youtubeBloomberg)
                }
                Section("More") {
                    NavigationLink("Attributions", value: DetailView.attributions)
                }
            }
        } detail: {
            switch detailView {
            case .fomcSpeeches:
                Speeches()
            case .fomcPressReleases:
                PressReleases()
            case .youtubeCNBC:
                // @CNBC on YouTube
                Interviews(channelId: "UCvJJ_dzjViJCoLf5uKUTwoA")
            case .youtubeCNBCTelevision:
                // @CNBCtelevision on YouTube
                Interviews(channelId: "UCrp_UI8XtuYfpiqluWLD7Lw")
            case .youtubeSixtyMinutes:
                // @60minutes on YouTube
                Interviews(channelId: "UCsN32BtMd0IoByjJRNF12cw")
            case .youtubeBloomberg:
                // @markets on YouTube
                Interviews(channelId: "UCIALMKvObZNtJ6AmdCLP7Lg")
            case .attributions:
                Attributions()
            default:
                ContentUnavailableView("Select a feed to view its contents", systemImage: "doc.fill")
            }
        }
    }
}

#Preview {
    MainView()
}
