//
//  AppEnvironment.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import Combine
import ComposableArchitecture
import PokemonShakespeareKit
import PokemonShakespeareUI

struct AppEnvironment {
  var pokemonManager: PokemonShakespeareKit
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var storage: Storage
}

struct Storage {
  var get: (String) -> Data?
  var set: (String, Data?) -> ()
}

extension Storage {
  static func live(storage: UserDefaults = UserDefaults.standard) -> Self {

    return .init(
      get: { key in
        return storage.data(forKey: key)
      },
      set: { key, value in
        storage.setValue(value, forKey: key)
      }
    )
  }

}

extension Data {
  func decoded<T: Codable>(_ type: T.Type) -> T? {
    return try? JSONDecoder().decode(type, from: self)
  }
}
