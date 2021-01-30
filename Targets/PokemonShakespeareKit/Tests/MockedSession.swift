//
//  MockedSession.swift
//  PokemonShakespeareKitTests
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
@testable import PokemonShakespeareKit
import Combine

struct MockedSession: DataTaskPublisherSession {

  var _anyDataTaskPublisher: (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>

  func anyDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
    self._anyDataTaskPublisher(request)
  }
}

extension MockedSession {
  static var unimplemented: Self {
    return .init { _ in fatalError() }
  }
}
