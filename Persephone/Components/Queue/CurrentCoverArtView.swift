//
//  CurrentCoverArtView.swift
//  Persephone
//
//  Created by Daniel Barber on 2019/4/27.
//  Copyright © 2019 Dan Barber. All rights reserved.
//

import AppKit
import ReSwift
import Kingfisher

class CurrentCoverArtView: NSImageView {
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    App.store.subscribe(self) {
      $0.select { $0.playerState.currentSong }
    }
  }

  func setAlbumImage(_ album: Album) {
    guard let imagePath = album.coverArtFilePath else { return }

    let imageURL = URL(fileURLWithPath: imagePath)
    let provider = LocalFileImageDataProvider(fileURL: imageURL)
    kf.setImage(
      with: .provider(provider),
      placeholder: NSImage.defaultCoverArt,
      options: [
        .processor(DownsamplingImageProcessor(size: .currentlyPlayingCoverSize)),
        .scaleFactor(2),
      ]
    )
  }
}

extension CurrentCoverArtView: StoreSubscriber {
  typealias StoreSubscriberStateType = Song?

  func newState(state: Song?) {
    guard let song = state else {
      image = .defaultCoverArt
      return
    }
    
    setAlbumImage(song.album)
  }
}
