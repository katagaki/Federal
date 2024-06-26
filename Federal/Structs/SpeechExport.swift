//
//  SpeechExport.swift
//  Federal
//
//  Created by シン on 2024/06/26.
//

import Foundation

struct SpeechExport: Codable {
    var title: String
    var link: String
    var `description`: String
    var category: String
    var publicationDate: Date
    var time: String
    var speaker: String
    var location: String
    var videoURL: String
    var contents: String
}
