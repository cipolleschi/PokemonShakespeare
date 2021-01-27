//
//  KitError.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation

public enum KitError: Error {
  case networkError(Error)
  case invalidURL(String)
  case invalidQueryText(String)
  case descriptionNotFound(String)
  case invalidTranslation
}

extension KitError {
  static func from(error: PokemonManager.Error) -> Self {
    switch error {
    case .networkError(let err):
      return .networkError(err)
    case .invalidURL(let url):
      return .invalidURL(url)
    }
  }
}

extension KitError {
  static func from(error: ShakespeareTranslator.Error) -> Self {
    switch error {
    case .networkError(let err):
      return .networkError(err)
    case .invalidURL(let url):
      return .invalidURL(url)
    case .invalidQueryText(let query):
      return .invalidQueryText(query)
    }
  }
}
