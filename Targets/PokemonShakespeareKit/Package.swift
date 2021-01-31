// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PokemonShakespeareKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PokemonShakespeareKit",
            targets: ["PokemonShakespeareKit"])
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "PokemonShakespeareKit",
            path: "Sources/",
            exclude: ["README.md"]

        ),
        .testTarget(
            name: "PokemonShakespeareKitTests",
            dependencies: ["PokemonShakespeareKit"]),
    ]
)