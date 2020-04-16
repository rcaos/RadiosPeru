//
//  FavoriteTableViewModel.swift
//  RadiosPeru
//
//  Created by Jeans Ruiz on 4/16/20.
//  Copyright © 2020 Jeans. All rights reserved.
//

import Foundation

final class FavoriteTableViewModel {
  
  var radioStation: StationRemote
  
  lazy var imageURL: URL? = {
    return URL(string: radioStation.pathImage)
  }()
  
  let titleStation: String?
  let detailStation: String?
  let isFavorite: Bool
  
  init(station: StationRemote) {
    self.radioStation = station
    
    titleStation = station.name
    detailStation = station.slogan
    isFavorite = true
  }
}
