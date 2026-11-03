// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "device_profile",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "device-profile", targets: ["device_profile"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "device_profile",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // The plugin collects nothing and tracks nobody; the manifest says so.
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
