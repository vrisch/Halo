// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Halo",
    products: [
        .library(
            name: "Halo",
            targets: ["Halo"]),
        ],
    targets: [
        .target(
            name: "Halo")
        ]
)
