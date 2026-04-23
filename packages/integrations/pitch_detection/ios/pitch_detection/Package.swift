// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "pitch_detection",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "pitch-detection", targets: ["pitch_detection"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.7.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "pitch_detection",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "AudioKit", package: "AudioKit"),
                .product(name: "SoundpipeAudioKit", package: "SoundpipeAudioKit"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
