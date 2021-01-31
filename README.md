# PokemonShakespeare

This project is a full project, containing three target:

* **PokemonShakespeare:** An app where the user is able to search for a pokemon, see it in a nice full screen view and save it into its favourites.
* **PokemonShakespeareKit:** A library whose duty is to interact with the pokemon service and the funtranslation service to get the pokemon description transalted in a fancy way.
* **PokemonShakespeareUI:** A UI library that contains some components to render the Pokemon. Specifically, it contains a full screen view and a table view cell.

## Preparing the project

The project leverages [Tuist](https://tuist.io) to create the project. In this way, it is not necessary to commit the `.xcodeproject` and the `.xcworkspace` files, typically a source of hard-to-solve git conflicts. The main advantage of `Tuist`is that it allows the iOS developers to describe their project in Swift, similarly to what SPM does.

To create the project, you can follow these steps:

1. Install Tuist: `bash <(curl -Ls https://install.tuist.io)`
2. Navigate to the project folder
3. Run `tuist generate`
4. Run `open PokemonShakespeare.xcworkspace` 

Tuist generates a `Project` folders which contains:

* A `Derived` folder with some Swift files auto generated with a few utilities
* A `Targets` folder with the three projects

Every project in the `Targets` folder follows the very same structure:

1. A `Sources` folder with all the source files
2. A `Tests` folder with the Tests
3. A `Resource` folder with the resources, this is created if and only if the target decalres some resources.

### PokemonShakespeare

This is the main app.

The app leverages the `PokemonShakespeareKit` to interact with the services to retrieve useful informations from the web. It also leverages the `PokemonShakespeareUI` library to render the pokemon on the screen.

The whole app uses `SwiftUI` as UI framework.
The logic is implemented using the [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) library, developed by Pointfree.co.

The pattern is mutuated from Redux, and follows the principles of the Unidirectional data flow.

* There is a unique `State` for the whole applications. It keeps track of all the user data.  
* The state is managed by the `Store`, which is the only entity able to modify it.
* The user interacts with the app by sending `actions`.
* These `actions`are handled by the store through a `reducer`
* The reducer is able to interact with the environment thanks to an `environment` struct which is allowed to executes side effect and to reinject actions in the store.

### PokemonShakespeareKit

This is the logic library that let the app communicate with external services.

You can find a more detailed description about how to integrate the library and how to use it in its [readme](./Targets/PokemonShakespeareKit/README.md).

The library is implemented by leveraging `Combine`, therefore a little bit of familiarity with the framework could help. All the public interfaces returns a `Publisher` of some kind and clients of the library can subscribe to the publishers to receive updates.

**Note on tests:** 

The library is tested a lot. It has mainly unit tests, but it also have some integration tests.

While the unit tests use mocks to avoid hitting the real backends, integration tests work with the actual endpoints.

The `funtranslation` server has a rate limit of 5 requests per hour. Therefore, if the tests are run several times in a single hour they will start failing.

In a proper production environment, we would have an API key to overcome this limitation

### PokemonShakespeareUI

This library contains the pokemon specific pieces of the UI.

I decided to separate the UI from the logic: in this way the `PokemonShakespeareKit` could be used also in mac applications, for example, and it can not depend on UI code.
Also, in this way, logic and UI are completely decoupled.

You can find a more detailed description about how to integrate the library and how to use it in its [readme](./Targets/PokemonShakespeareUI/README.md).

The library uses another dependency to load images from the web. The library is called [Kingfisher](https://github.com/onevcat/Kingfisher) and it is a basic dependency in several swift projects.

The library supports both SwiftUI and UIKit.

**Note on tests:**

To test the UI, I leveraged a technique called snapshot testing. UITests are long, cumbersome and most of the time they are flaky.

Snapshot testing works by creating the view and taking a snapshot in the very first iteration. Any other iteration works by comparing the snapshot with the reference taken in the first round. If the two are equal, the test passes.

This is achieved with this [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library.


 