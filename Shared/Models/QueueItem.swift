//
//  SongItem.swift
//  Persephone
//
//  Created by Daniel Barber on 2019/2/20.
//  Copyright © 2019 Dan Barber. All rights reserved.
//

import AppKit

struct QueueItem: Hashable {
  var song: Song
  var queuePos: Int
  var isPlaying: Bool
}
