//
//  AudioFile.swift
//  LambdaTimeline
//
//  Created by Patrick Millet on 6/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioComment: FirebaseConvertible, Equatable {
    
    static private let audioKey = "audio"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    let audio: Data
    let author: Author
    let timestamp: Date
    
    init(audio: Data, author: Author, timestamp: Date = Date()) {
        self.audio = audio
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard let audio = dictionary[AudioComment.audioKey] as? Data,
            let authorDictionary = dictionary[AudioComment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[AudioComment.timestampKey] as? TimeInterval else { return nil }
        
        self.audio = audio
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [AudioComment.audioKey: audio,
                AudioComment.author: author.dictionaryRepresentation,
                AudioComment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: AudioComment, rhs: AudioComment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
