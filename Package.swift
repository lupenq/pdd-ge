// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "pdd-ge",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "pdd-ge",
            targets: ["pdd-ge"]
        )
    ],
    targets: [
        .executableTarget(
            name: "pdd-ge"
        )
    ]
)
