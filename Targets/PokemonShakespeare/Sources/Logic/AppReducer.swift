//
//  AppReducer.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import ComposableArchitecture
import PokemonShakespeareUI
import PokemonShakespeareKit
import UIKit
import Combine

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>
extension AppReducer {
  static var live: Self {
    return .init { state, action, environment in
      switch action {
      case .searchPokemon(let pokemonName):

        let lowercasedName = pokemonName.lowercased()
        state.networkCallInFlight = true
        return environment.pokemonManager.description(for: lowercasedName)
          .zip(
            environment.pokemonManager.originalArtwork(for: lowercasedName),
            environment.pokemonManager.sprite(for: lowercasedName))
          .receive(on: UIScheduler.shared)
          .map { (description, artwork, sprite) -> Pokemon in
            return Pokemon(
              name: pokemonName.capitalized,
              artwork: artwork,
              description: description,
              sprite: sprite
            )
          }
          .catchToEffect()
          .map(AppAction.onPokemonFound)

      case .onPokemonFound(let result):
        state.networkCallInFlight = false
        state.pokemonFound = nil
        state.searchError = nil
        switch result {
        case .success(let pokemon):
          state.pokemonFound = pokemon
          state.showPokemon = true
        break
        case .failure(let error):
          state.searchError = error.localizedDescription
        }

        return .none
      case .cleanupPokemonFound:
        state.pokemonFound = nil
        return .none
      case .cleanupError:
        state.searchError = nil
        return .none
      case .changeFavourite(let pokemon):
        if state.favouritePokemons.contains(pokemon) {
          state.favouritePokemons.remove(pokemon)
        } else {
          state.favouritePokemons.insert(pokemon)
        }
        return .none
      case .dismissPokemon:
        state.showPokemon = false
        return .none
      case .dismissLoader:
        state.networkCallInFlight = false
        return .none
      }
    }
  }
}

extension AppReducer {
  static var stateKey = "persistence.state"
  static let persistence: Self = .init { (state, _, environment) -> Effect<AppAction, Never> in
    environment.storage.set(Self.stateKey, state.encoded)
    return .none
  }
}

extension AppState {
  var encoded: Data? {
    return try? JSONEncoder().encode(self)
  }
}
