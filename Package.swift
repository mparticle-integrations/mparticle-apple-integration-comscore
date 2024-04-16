// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mParticle-ComScore",
    platforms: [ .iOS(.v11), .tvOS(.v11) ],
    products: [
        .library(
            name: "mParticle-ComScore",
            targets: ["mParticle-ComScore"]),
    ],
    dependencies: [
      .package(
          name: "mParticle-Apple-SDK",
          url: "https://github.com/mParticle/mparticle-apple-sdk",
          .upToNextMajor(from: "8.0.0")
      ),
      .package(
          name: "ComScore",
          url: "https://github.com/comScore/Comscore-Swift-Package-Manager",
          .upToNextMajor(from: "6.12.3")
      )
    ],
    targets: [
        .target(
            name: "mParticle-ComScore",
            dependencies: [
                .byName(name: "mParticle-Apple-SDK"),
                .byName(name: "ComScore"),
            ],
            path: "mParticle-ComScore",
            publicHeadersPath: "."
        )
    ]
)
