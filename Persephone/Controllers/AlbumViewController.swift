//
//  AlbumViewController.swift
//  Persephone
//
//  Created by Daniel Barber on 2019/2/08.
//  Copyright © 2019 Dan Barber. All rights reserved.
//

import AppKit
import ReSwift
import Differ

class AlbumViewController: NSViewController,
                           NSCollectionViewDelegateFlowLayout {
  var dataSource = AlbumDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    App.store.subscribe(self) {
      $0.select { $0.albumListState }
    }

    albumScrollView.postsBoundsChangedNotifications = true

    albumCollectionView.dataSource = dataSource

    registerForDragAndDrop(albumCollectionView)
  }

  deinit {
    App.store.unsubscribe(self)
  }

  override func viewWillLayout() {
    super.viewWillLayout()

    if let layout = albumCollectionView.collectionViewLayout as? AlbumViewLayout {
      layout.saveScrollPosition()
    }

    albumCollectionView.collectionViewLayout?.invalidateLayout()
  }

  override func viewDidLayout() {
    super.viewDidLayout()

    guard let layout = albumCollectionView.collectionViewLayout as? AlbumViewLayout
      else { return }

    layout.setScrollPosition()
  }

  @IBOutlet var albumScrollView: NSScrollView!
  @IBOutlet var albumCollectionView: NSCollectionView!
}

extension AlbumViewController: StoreSubscriber {
  typealias StoreSubscriberStateType = AlbumListState

  func newState(state: StoreSubscriberStateType) {
    let oldAlbums = dataSource.albums
    
    dataSource.albums = state.albums

    albumCollectionView.animateItemChanges(
      oldData: oldAlbums,
      newData: dataSource.albums
    )
  }
}
