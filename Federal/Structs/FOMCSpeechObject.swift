//
//  FOMCSpeechObject.swift
//  Federal
//
//  Created by シン on 2024/06/20.
//

import Foundation

// Source: https://www.federalreserve.gov/json/ne-speeches.json

struct FOMCSpeechObject: Decodable {
    let date: Date?
    let title: String?
    let speaker: String?
    let location: String?
    let link: String?
    let revision: String?
    let o: String?
    let videoLink: String?
    let isVideo: Bool?
    let updateDate: String?

    enum CodingKeys: String, CodingKey {
        case date = "d"
        case title = "t"
        case speaker = "s"
        case location = "lo"
        case link = "l"
        case revision = "a"
        case o = "o"
        case videoLink = "v"
        case isVideo = "video"
        case updateDate = "updateDate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateFormatterFull = DateFormatter()
        let dateFormatterDateOnly = DateFormatter()
        dateFormatterFull.dateFormat = "MM/dd/yyyy h:mm:ss a"
        dateFormatterDateOnly.dateFormat = "MM/dd/yyyy"
        let dateString = try container.decodeIfPresent(String.self, forKey: .date)
        if let dateString {
            if let date = dateFormatterFull.date(from: dateString) {
                self.date = date
            } else if let date = dateFormatterDateOnly.date(from: dateString) {
                self.date = date
            } else {
                self.date = nil
            }
        } else {
            self.date = nil
        }
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.speaker = try container.decodeIfPresent(String.self, forKey: .speaker)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        let linkPath = try container.decodeIfPresent(String.self, forKey: .link)
        if let linkPath {
            self.link = "https://www.federalreserve.gov\(linkPath)"
        } else {
            self.link = nil
        }
        self.revision = try container.decodeIfPresent(String.self, forKey: .revision)
        self.o = try container.decodeIfPresent(String.self, forKey: .o)
        self.videoLink = try container.decodeIfPresent(String.self, forKey: .videoLink)
        let videoFlag = try container.decodeIfPresent(String.self, forKey: .isVideo)
        self.isVideo = videoFlag == "Yes"
        self.updateDate = try container.decodeIfPresent(String.self, forKey: .updateDate)
    }
}
