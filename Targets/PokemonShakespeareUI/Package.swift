// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PokemonShakespeareUI",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PokemonShakespeareUI",
            targets: ["PokemonShakespeareUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "6.0.0"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.1")
    ],
    targets: [
        .target(
            name: "PokemonShakespeareUI",
            dependencies: ["Kingfisher"],
            path: "Sources/",
            exclude: ["README.md"]
        ),
        .testTarget(
            name: "PokemonShakespeareUITests",
            dependencies: ["PokemonShakespeareUI", "SnapshotTesting"]),
    ]
)