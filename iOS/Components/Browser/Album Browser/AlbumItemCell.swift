//
//  AlbumItemCell.swift
//  Persephone
//
//  Created by Daniel Barber on 2020-3-28.
//  Copyright © 2020 Dan Barber. All rights reserved.
//

import UIKit
import Kingfisher

class AlbumItemCell: UICollectionViewCell {
  var album: Album?
  
  override func didMoveToSuperview() {
    albumCoverView.layer.backgroundColor = UIColor.black.cgColor
    albumCoverView.layer.cornerRadius = 4
    albumCoverView.layer.borderWidth = 0.5
    albumCoverView.layer.masksToBounds = true
    setAppearance()
  }
  
  func setAlbum(_ album: Album) {
    self.album = album
    albumTitle.text = album.title
    albumArtist.text = album.artist
    setAlbumCover(album)
  }
  
  func setAlbumCover(_ album: Album) {
    guard let song = album.mpdAlbum.firstSong
      else { return }

    let provider = MPDAlbumArtImageDataProvider(
      songUri: song.uriString,
      cacheKey: album.hash
    )

    albumCoverView.kf.setImage(
      with: .provider(provider),
      placeholder: UIImage(named: "defaultCoverArt"),
      options: [
        .processor(DownsamplingImageProcessor(size: .albumListCoverSize)),
        .scaleFactor(traitCollection.displayScale),
      ]
    ) { result in
      switch result {
      case .success(let imageResult):
        guard let imageData = imageResult.image.pngData()
          else { return }
        
        let _ = RawImageDataProvider(
          data: imageData,
          cacheKey: album.hash
        )
        
      case .failure(_):
        break
      }
    }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setAppearance()
  }
  
  func setAppearance() {
    let darkMode = traitCollection.userInterfaceStyle == .dark

    albumCoverView.layer.borderColor = darkMode ? CGColor.albumBorderColorDark : CGColor.albumBorderColorLight
  }

  @IBOutlet var albumCoverView: UIImageView!
  @IBOutlet var albumTitle: UILabel!
  @IBOutlet var albumArtist: UILabel!
}