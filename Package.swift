// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GUCoordinates",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GUCoordinates",
            targets: ["GUCoordinates"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GUUnits", url: "ssh://git.mipal.net/git/swift_GUUnits.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .systemLibrary(name: "CGUCoordinates", pkgConfig: "libgucoordinates"),
        .target(
            name: "GUCoordinates",
            dependencies: ["CGUCoordinates", "GUUnits"]),
        .testTarget(
            name: "GUCoordinatesTests",
            dependencies: ["GUCoordinates", "CGUCoordinates"]),
    ]
)
