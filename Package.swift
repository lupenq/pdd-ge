// swift-tools-version: 6.2
import PackageDescription

var products: [Product] = [
    .executable(
        name: "pdd-ge",
        targets: ["pdd-ge"]
    )
]

#if canImport(UIKit)
products.append(
    .iOSApplication(
        name: "PddGe",
        targets: ["pdd-ge"],
        bundleIdentifier: "com.pddge.app",
        teamIdentifier: "TEAMID",
        displayVersion: "1.0",
        bundleVersion: "1",
        appCategory: .education,
        supportedDeviceFamilies: [.phone, .pad],
        supportedInterfaceOrientations: [.portrait],
        infoPlist: .extendingDefault(with: ["UILaunchScreen": [:]])
    )
)
#endif

let package = Package(
    name: "pdd-ge",
    platforms: [
        .iOS(.v17)
    ],
    products: products,
    targets: [
        .executableTarget(
            name: "pdd-ge"
        )
    ]
)
