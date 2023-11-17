//
//  SwipeLog.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/16/23.
//

import Foundation

struct SwipeLogEntry {
    let song: DisplaySong
    let action: SwipeAction
    let timestamp: Date
}

enum SwipeAction {
    case liked
    case disliked
    case skipped
}
