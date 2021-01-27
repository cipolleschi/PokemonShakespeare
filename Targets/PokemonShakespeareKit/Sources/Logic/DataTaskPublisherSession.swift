//
//  DataTaskPublisherSession.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import Combine

// MARK: Protocols
/// Protocol that defines the minimum set of capabilities for the URLSession.
/// In this way it will be easier to mock the session in the translator
protocol DataTaskPublisherSession {
  func anyDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>

}

/// Automatic conformance to the `DataTaskPublisherSession` protocol
extension URLSession: DataTaskPublisherSession {
  func anyDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    return self.dataTaskPublisher(for: request).eraseToAnyPublisher()
  }
}
