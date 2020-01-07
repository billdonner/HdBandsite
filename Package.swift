// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Hd",
    products: [
        .executable(name: "Hd", targets: ["Hd"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.1.0"),
        .package(url:"https://github.com/tid-kijyun/Kanna.git",from:"5.0.0")
    ],
    targets: [
        .target(
            name: "Hd",
            dependencies: ["Publish","Kanna"]
        )
    ]
)
