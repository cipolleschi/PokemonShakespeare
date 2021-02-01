# PokemonShakespeareUI

This is a package that contains the UI to some components based on some pokemon information.  
The package has no other logic than UI visualization. You can use whatever content provider you prefer.

## Integration

**Supported Versions:** iOS >= 14

To integrate this library into an app, you can clone the project.   
Once the project has been cloned, do the following:

1. Click on `File` > `Swift Packages` > `Add Package Dependencies`
2. In the textbox, type `file:///path/to/PokemonShakespeare/Targets/PokemonShakespeareUI` replacing `path/to` with the root directory where you have cloned the project.
3. Click on Next twice.

Don't forget to add the dependency to your app:

1. Click on the blue Xcode icon in the Project Navigator
2. Select your app name below the Target Panel.
3. In the General tab, scroll down to the `Framework, Libraries and Embedded Content` section
4. Click on the `+` button
5. Select the `PokemonShakespeareUI` target

Now, you can use it in your app by simply importing it.

## Usage

The library offers two components: a full-screen component and a table view cell.  
The components can be used with both `SwiftUI` and `UIKit`.

Each component comes with its own `ViewModel`. The MVVM pattern is enforced within the component, just set the new model, and you are good to go.

### FullScreen Component (UIKit)

```swift

let fullscreen = PokemonFullScreen()
fullscreen.viewModel = PokemonVM(
  artworkURL: nil,
  artworkLoadingImage: UIImage(named: "anImage.png")!,
  name: "Pikachu",
  description: "An electric mouse"
)

```
### CellComponent (UIKit)

```swift
let cell = PokemonCell()
cell.viewModel = PokemonCellVM(
  name: "Pikachu",
  spriteURL: nil,
  spriteLoadingImage: UIImage(named: "anImage.png")!
)
```

### FullScreen Component (SwiftUI)

```swift
struct AView: View {

	var body: some View {
		PokemonFullScreenSwiftUI(pokemonModel: PokemonVM(
				artworkURL: nil, 
				artworkLoadingImage: UIImage(named: "anImage.png")!, 
				name: "Pikachu", 
				description: "An electric mouse"
			)
		)
	}
}
```

### CellComponent (SwiftUI)

```swift
struct AView: View {

	var body: some View {
		PokemonCellSwiftUI(pokemonCellVM: PokemonCellVM(
				name: "Pikachu",
  			spriteURL: nil,
  			spriteLoadingImage: UIImage(named: "anImage.png")!
			)
		)
	}
}
```

### Provider

The library also comes with a UI provider that can be used as a single interface to access the components.  
The provider can be used when you need to retrieve the components, but you don't care about their type.

```swift
// Obtain a reference to the provider
let uiProvider = PokemonShakespeareUIProvider.live

// The full screen model
let pokemonVM = PokemonVM(
				artworkURL: nil, 
				artworkLoadingImage: UIImage(named: "anImage.png")!, 
				name: "Pikachu", 
				description: "An electric mouse"
			)

// The cell model
let pokemonCellVM = PokemonCellVM(
				name: "Pikachu",
  			spriteURL: nil,
  			spriteLoadingImage: UIImage(named: "anImage.png")!
			)

// Get references to all the classes
let uiKitFullScreen = uiProvider.UIKitFullScreenComponent(for: pokemonVM)
let swiftUIFullScreen = uiProvider.swiftUIFullScreenComponent(for: pokemonVM)
let uiKitCell = uiProvider.UIKitCellComponent(for: pokemonCellVM)
let swiftUICell = uiProvider.swiftUICellComponent(for: pokemonCellVM)
```