// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PieChart",
            type: .static,
            targets: ["PieChart"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PieChart",
            dependencies: []
        ),
        .testTarget(
            name: "PieChartTests",
            dependencies: ["PieChart"]
        ),
    ]
) 
