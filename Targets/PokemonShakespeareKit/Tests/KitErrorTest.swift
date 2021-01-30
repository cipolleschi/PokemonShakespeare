//
//  TestKitError.swift
//  PokemonShakespeareKitTests
//
//  Created by Riccardo Cipolleschi on 27/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import XCTest
@testable import PokemonShakespeareKit

class KitErrorTest: XCTestCase {
  func testFrom_PokemonManagerError_whenInvalidURL() throws {
    let notAnUrl = "this.is.not.an.url"
    let error = KitError.from(error: PokemonManager.Error.invalidURL(notAnUrl))

    switch error {
    case .invalidURL(let url):
      XCTAssertEqual(url, notAnUrl)
    default:
      XCTFail("Should not reach this point")
    }
  }

  func testFrom_PokemonManagerError_whenNetworkError() throws {
    let nserror = NSError(domain: "NSURLErrorDomain", code: -1, userInfo: nil)
    let expectedError = URLError(.unknown, userInfo: ["error": nserror])
    let error = KitError.from(error: PokemonManager.Error.networkError(expectedError))

    switch error {
    case .networkError(let err):
    XCTAssertEqual(err, expectedError)
    default:
      XCTFail("Should not reach this point")
    }
  }

  func testFrom_PokemonManagerError_whenPokemonNotFound() throws {
    let expectedError = URLError(.unknown)
    let error = KitError.from(error: PokemonManager.Error.networkError(expectedError))

    switch error {
    case .pokemonNotFound:
      XCTAssert(true, "The test should create a pokemonNotFound error")
    default:
      XCTFail("Should not reach this point")
    }
  }

  func testFrom_ShakespeareTranslator_whenInvalidURL() throws {
    let notAnUrl = "this.is.not.an.url"
    let error = KitError.from(error: ShakespeareTranslator.Error.invalidURL(notAnUrl))

    switch error {
    case .invalidURL(let url):
      XCTAssertEqual(url, notAnUrl)
    default:
      XCTFail("Should not reach this point")
    }
  }

  func testFrom_ShakespeareTranslator_whenNetworkError() throws {
    let expectedError = URLError(.unknown)
    let error = KitError.from(error: ShakespeareTranslator.Error.networkError(expectedError))

    switch error {
    case .networkError(let err):
      XCTAssertEqual(err, expectedError)
    default:
      XCTFail("Should not reach this point")
    }
  }

  func testFrom_ShakespeareTranslator_when() throws {
    let expectedQueryText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    let error = KitError.from(error: ShakespeareTranslator.Error.invalidQueryText(expectedQueryText))

    switch error {
    case .invalidQueryText(let query):
      XCTAssertEqual(query, expectedQueryText)
    default:
      XCTFail("Should not reach this point")
    }
  }

}
