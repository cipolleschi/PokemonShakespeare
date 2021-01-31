//
//  AppAction.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import PokemonShakespeareUI
import PokemonShakespeareKit

enum AppAction: Equatable {
  case searchPokemon(String)
  case onPokemonFound(Result<Pokemon, KitError>)
  case cleanupPokemonFound
  case cleanupError
  case changeFavourite(Pokemon)
  case dismissPokemon
  case dismissLoader
}
