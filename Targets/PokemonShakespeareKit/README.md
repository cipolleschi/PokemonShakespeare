# PokemonShakespeareKit

This is the package that contains the logic that contacts remote services to retrieve information.  
This package has no UI, so you are not forced to use the `PokemonShakespeareUI` package if you don't want to.

## Integration

**Supported versions:** iOS > 14; MacOS > 11.0 

To integrate `PokemonShakespeareKit` you can use the Swift Package Manager (SPM).

You can clone the project and then add the following lines:

```swift
dependencies: [
  // ...
  .package(path: "path/to/PokemonShakespeare/Targets/PokemonShakespeareKit")
]
```

And then, remember to add it as a dependenci of a target that needs it. For example:

```swift
targets: [
  .target(
    name: "YourTarget",
    dependencies: ["PokemonShakespeareKit"]),
  )
  //...
]
```

Once that is done, you should be able to use `ShakespearePokemonKit` by only doing:

```swift
import PokemonShakespeareKit

// Your swift file
```

## Usage

`PokemonShakespeareKit` is very easy to use.

It comes with a struct called `PokemonShakespeareKit`, which encapsulates all the library's operations.  
The `kit` is using `Combine` to carry out all the relevant operations. Therefore you could need to get familiar with that.

To get a reference to the `kit`, you can do:

```swift

let kit = PokemonShakespeareKit.live
```

The kit offers three different methods. Each method returns a `Publisher`of some kind. And all the methods take the name of a pokemon as a parameter:

```swift

kit.description(for: "Pikachu") // it returns a Publisher<String?, KitError>

kit.originalArtwork(for: "Pikachu") // it returns a Publisher<URL?, KitError>

kit.sprite(for: "Pikachu") // it returns a Publisher<URL?, KitError>
```

The obtained description are already translated into Shakespeare's language.

As you can see, the errors are all in the `KitError` shape.

### Combine Publishers Together

A common pattern to use the library could be to combine publishers.  
The following example allows you to create a composed publisher. 

```swift
// Set of cancellables. It is mandatory. Otherwise, the publisher won't publish its values
var cancellables: Set<AnyCancellable> = []

// Starts with the description publisher. Zip the artwork and sprites with it.
kit.description(for: "Pikachu")
  .zip(kit.originalArtwork(for: "Pikachu"),
       kit.sprite(for: "Pikachu")
  ).sink { completion in
    switch completion {
    case .failure(let error):
      // Handle the error
      break
    case .finished:
      // the publisher finished to emit their values
    break
    }

  } receiveValue: { description, artworkURL, spriteURL in
    //create the object you need with the above informations
  }
  .store(in: &cancellables)
```

### Optimization Notes

The framework offers a few optimizations: it caches the pokemon internally so that if you ask for the sprite and then for the artwork, the pokemon is not downloaded twice. 