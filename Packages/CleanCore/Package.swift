// swift-tools-version: 5.9
import PackageDescription

// The dependency rule, enforced by the compiler:
//   Domain      -> (nothing)
//   DataLayer   -> Domain
// The app target (Presentation + composition root) is the only place that sees both.
let package = Package(
    name: "CleanCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "DataLayer", targets: ["DataLayer"])
    ],
    targets: [
        .target(name: "Domain"),
        .target(
            name: "DataLayer",
            dependencies: ["Domain"],
            resources: [.process("Persistence/Favorites.xcdatamodeld")]
        ),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
        .testTarget(name: "DataLayerTests", dependencies: ["DataLayer", "Domain"])
    ]
)
