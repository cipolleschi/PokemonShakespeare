//
//  KitError.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation

/// Main error that the SDK can throw. It uses this error to communicate with its clients
public enum KitError: Error, Equatable, LocalizedError {

  /// Thrown when there is a network error
  case networkError(URLError)
  /// Thrown when the URL is invalid
  case invalidURL(String)

  /// Thrown when the query for the description is invalid
  case invalidQueryText(String)

  /// Thrown when a pokemon has no description
  case descriptionNotFound(String)

  /// Thrown when a translation is invalid
  case invalidTranslation

  /// Thrown when a pokemon is not found
  case pokemonNotFound

  /// Thrown when the user hits the rate limit with the translation service
  case rateLimitHit

  /// Human-readable description of the error
  public var errorDescription: String? {
    switch self {
    case .networkError(let err):
      return "Something went wrong. Please try again in a few minutes.\n(Error code: \(err.errorCode))"
    case .invalidURL(let url):
      return "The requested url is invalid.\nURL: \(url)"
    case .invalidQueryText(let queryText):
      return "The query requested is invalid.\nQuery: \(queryText)"
    case .descriptionNotFound(let pokemon):
      return "We cannot found the description for \(pokemon)"
    case .invalidTranslation:
      return "The translation is invalid"
    case .pokemonNotFound:
      return "We cannot found the pokemon you are searching"
    case .rateLimitHit:
      return "We hit the rate limit. Please wait for some minutes before trying again"
    }
  }
}

// MARK: - Helpers
extension KitError {
  static func from(error: PokemonManager.Error) -> Self {
    switch error {
    case .networkError(let err):
      if err.code == .unknown && err.userInfo.isEmpty {
        return .pokemonNotFound
      }

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

      if
        let error = err.userInfo["error"],
        let shakeSpeareError = error as? ShakespeareTranslator.Error {
        return KitError.from(error: shakeSpeareError)
      }

      return .networkError(err)
    case .invalidURL(let url):
      return .invalidURL(url)
    case .invalidQueryText(let query):
      return .invalidQueryText(query)
    case .rateLimitHit:
      return .rateLimitHit
    }
  }
}
