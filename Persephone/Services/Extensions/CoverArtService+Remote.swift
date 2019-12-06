//
//  CoverArtService+Remote.swift
//  Persephone
//
//  Created by Daniel Barber on 2019/3/17.
//  Copyright © 2019 Dan Barber. All rights reserved.
//

import AppKit
import SwiftyJSON
import PromiseKit
import PMKFoundation

extension CoverArtService {
  enum RemoteArtworkError: Error {
    case noArtworkAvailable
    case notConfigured
  }

  func getRemoteArtwork() -> Promise<NSImage?> {
    return Promise { seal in
      if App.store.state.preferencesState .fetchMissingArtworkFromInternet {
        CoverArtService.coverArtQueue.async {
          let coverArtWorkItem = DispatchWorkItem {
            self.getArtworkFromMusicBrainz().map(Optional.some).pipe(to: seal.resolve)
          }

          CoverArtQueue.shared.addToQueue(workItem: coverArtWorkItem)
        }
      } else {
        throw RemoteArtworkError.notConfigured
      }
    }
  }

  func getArtworkFromMusicBrainz() -> Promise<NSImage> {
    var search = URLComponents(string: "https://musicbrainz.org/ws/2/release/")!
    search.query = "query=artist:\(album.artist) AND release:\(album.title) AND country:US&limit=1&fmt=json"

    return firstly {
      URLSession.shared.dataTask(.promise, with: search.url!).validate()
    }.compactMap {
      JSON($0.data)
    }.compactMap {
      $0["releases"][0]["id"].string
    }.compactMap {
      URLComponents(string: "https://coverartarchive.org/release/\($0)/front-500")?.url
    }.then { (url: URL?) -> Promise<(data: Data, response: URLResponse)> in
      return URLSession.shared.dataTask(.promise, with: url!).validate()
    }.compactMap {
      NSImage(data: $0.data)?.toFitBox(
        size: NSSize(width: self.cachedArtworkSize, height: self.cachedArtworkSize)
      )
    }.recover { error -> Promise<NSImage> in
      if case PMKHTTPError.badStatusCode(404, _, _) = error {
        throw RemoteArtworkError.noArtworkAvailable
      } else {
        throw error
      }
    }
  }
}
