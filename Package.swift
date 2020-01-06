// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Hd",
    products: [
        .executable(name: "Hd", targets: ["Hd"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Hd",
            dependencies: ["Publish"]
        )
    ]
)