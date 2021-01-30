//
//  ShakespearTranslator.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import Combine

struct ShakespeareTranslator {
  enum Error: Swift.Error {
    case invalidURL(String)
    case invalidQueryText(String)
    case networkError(URLError)
  }

  private init(_translation: @escaping (_ for: String) throws -> AnyPublisher<String, Error>) {
    self._translation = _translation
  }

  private var _translation: (_ for: String) throws -> AnyPublisher<String, Error>

  func translation(for text: String) throws ->  AnyPublisher<String, Error> {
    return try self._translation(text)
  }
}

// MARK: - Live Implementation
extension ShakespeareTranslator {
  // Internal structure to decode the response
  struct FuntranslationResult: Codable {
    struct Success: Codable {
      var total: Int
    }
    struct Contents: Codable {
      var translated: String
      var text: String
      var translation: String
    }

    var success: Success
    var contents: Contents
  }
  
  /// Function that returns a `ShakespeareTranslator` instance.
  /// - parameters session: The session that has to be used to send the request. Used to implement Dependency Injection
  /// - returns an instance of the Shakespeare translator
  static func live(session: DataTaskPublisherSession = URLSession.shared) -> Self {

    return Self { text in
      // Input validation: query
      guard let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        throw Error.invalidQueryText(text)
      }

      let baseURLString = "https://api.funtranslations.com/translate/shakespeare.json?text=\(urlEncodedText)"

      // Input validation: URL
      guard let url = URL(string: baseURLString) else {
        throw Error.invalidURL(baseURLString)
      }


      let urlRequest = URLRequest(url: url)

      // Perfoming the request.
      // Data publisher returns a tuple (Data, Result).
      // The first map extracts the data, so that we can decode it.
      // Once we have decoded the result, we can extract the translation.
      return session
        .anyDataTaskPublisher(for: urlRequest)
        .map(\.data)
        .decode(type: FuntranslationResult.self, decoder: JSONDecoder())
        .map(\.contents.translated)
        .mapError{ error in
          let urlError = error as? URLError ?? URLError(.unknown, userInfo: ["error": error])
          return ShakespeareTranslator.Error.networkError(urlError)
        }
        .eraseToAnyPublisher()
    }
  }
}

#if DEBUG
extension ShakespeareTranslator {
  static var unimplemented: Self {
    return .init(_translation: { _ in fatalError() })
  }
}
#endif
