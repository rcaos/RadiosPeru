//
//  PlayerViewModel.swift
//  RadiosPeru
//
//  Created by Jeans on 10/18/19.
//  Copyright © 2019 Jeans. All rights reserved.
//

import RxSwift

final class PlayerViewModel {
  
  private let toggleFavoritesUseCase: ToggleFavoritesUseCase
  
  private let askFavoriteUseCase: AskFavoriteUseCase
  
  private var radioPlayer: RadioPlayer?
  
  private var stationSelected: StationRemote
  
  private let viewStateBehaviorSubject = BehaviorSubject<RadioPlayerState>(value: .stopped)
  private let isFavoriteBehaviorSubject = BehaviorSubject<Bool>(value: false)
  private let stationNameBehaviorSubject = BehaviorSubject<String>(value: "Pick a Radio Station")
  private let stationDescriptionBehaviorSubject = BehaviorSubject<String>(value: "")
  private let stationURLBehaviorSubject = BehaviorSubject<URL?>(value: nil)
  
  private let disposeBag = DisposeBag()
  
  public var input: Input
  
  public var output: Output
  
  // MARK: - Initializers
  
  init(toggleFavoritesUseCase: ToggleFavoritesUseCase,
       askFavoriteUseCase: AskFavoriteUseCase,
       player: RadioPlayer?,
       station: StationRemote) {
    
    self.toggleFavoritesUseCase = toggleFavoritesUseCase
    self.askFavoriteUseCase = askFavoriteUseCase
    
    self.stationSelected = station
    self.radioPlayer = player
    
    self.input = Input()
    self.output = Output(viewState: viewStateBehaviorSubject.asObservable(),
                         isFavorite: isFavoriteBehaviorSubject.asObservable(),
                         stationName: stationNameBehaviorSubject.asObservable(),
                         stationDescription: stationDescriptionBehaviorSubject.asObservable(),
                         stationURL: stationURLBehaviorSubject.asObservable())
    
    setupRadio(with: stationSelected)
  }
  
  // MARK: - Private
  
  private func setupRadio(with station: StationRemote) {
    stationNameBehaviorSubject.onNext(station.name)
    stationURLBehaviorSubject.onNext( URL(string: station.pathImage))
    checkIsFavorite(with: station)
    subscribe(to: radioPlayer)
  }
  
  private func subscribe(to radioPlayer: RadioPlayer?) {
    guard let radioPlayer = radioPlayer else { return }
    
    radioPlayer.statePlayerBehaviorSubject
      .bind(to: viewStateBehaviorSubject)
      .disposed(by: disposeBag)
    
    radioPlayer.airingNowBehaviorSubject
      .bind(to: stationDescriptionBehaviorSubject)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Public
  
  func togglePlayPause() {
    guard let player = radioPlayer else { return }
    player.togglePlayPause()
  }
  
  func markAsFavorite() {
    let simpleStation = SimpleStation(name: stationSelected.name, id: stationSelected.id)
    
    let request = ToggleFavoriteUseCaseRequestValue(station: simpleStation)
    
    toggleFavoritesUseCase.execute(requestValue: request)
      .subscribe(onNext: { [weak self] isFavorite in
        guard let strongSelf = self else { return }
        strongSelf.isFavoriteBehaviorSubject.onNext(isFavorite)
      })
      .disposed(by: disposeBag)
  }
  
  private func checkIsFavorite(with station: StationRemote?) {
    guard let station = station else { return  }
    
    let simpleStation = SimpleStation(name: station.name, id: station.id)
    let request = AskFavoriteUseCaseRequestValue(station: simpleStation)
    
    askFavoriteUseCase.execute(requestValue: request)
      .subscribe(onNext: { [weak self] isFavorite in
        guard let strongSelf = self else { return }
        strongSelf.isFavoriteBehaviorSubject.onNext(isFavorite)
      })
      .disposed(by: disposeBag)
  }
}

extension PlayerViewModel {
  
  public struct Input { }
  
  public struct Output {
    
    let viewState: Observable<RadioPlayerState>
    
    let isFavorite: Observable<Bool>
    
    let stationName: Observable<String>
    
    let stationDescription: Observable<String>
    
    let stationURL: Observable<URL?>
  }
}
