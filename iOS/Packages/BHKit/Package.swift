// swift-tools-version: 6.0
import PackageDescription

// BHKit — én lokal pakke med målrettede targets (research.md R-002).
//
// Afhængighedsretningen er en del af arkitekturen og håndhæves af denne fil:
//
//   BHContracts     → Foundation                      (wire-typerne, ingen adfærd)
//   BHGameCore      → BHContracts                     (ren logik, nul Apple-frameworks)
//   BHContentKit    → BHContracts                     (kilde og repository)
//   BHPersistence   → BHContracts, BHGameCore         (hændelseslog og fold)
//   BHLocationKit   → BHContracts, BHGameCore + CoreLocation
//   BHDesignSystem  → SwiftUI
//   BHAuthenticationKit → Foundation, Security
//
// macOS står på platformslisten alene for at gøre `swift test` muligt uden
// simulator. Appen bygges og udgives kun til iOS (plan.md, Target Platform).
let package = Package(
    name: "BHKit",
    defaultLocalization: "da",
    platforms: [
        .iOS(.v18),
        .macOS(.v14),
    ],
    products: [
        .library(name: "BHContracts", targets: ["BHContracts"]),
        .library(name: "BHGameCore", targets: ["BHGameCore"]),
        .library(name: "BHContentKit", targets: ["BHContentKit"]),
        .library(name: "BHPersistence", targets: ["BHPersistence"]),
        .library(name: "BHLocationKit", targets: ["BHLocationKit"]),
        .library(name: "BHDesignSystem", targets: ["BHDesignSystem"]),
        .library(name: "BHAuthenticationKit", targets: ["BHAuthenticationKit"]),
    ],
    targets: [
        .target(name: "BHContracts"),
        .target(name: "BHGameCore", dependencies: ["BHContracts"]),
        .target(name: "BHContentKit", dependencies: ["BHContracts"]),
        .target(name: "BHPersistence", dependencies: ["BHContracts", "BHGameCore"]),
        .target(
            name: "BHLocationKit",
            dependencies: ["BHContracts", "BHGameCore"]
        ),
        .target(name: "BHDesignSystem"),
        .target(
            name: "BHAuthenticationKit",
            linkerSettings: [.linkedFramework("Security")]
        ),

        // Kun til test. Finder `contracts/` på disk, så testene læser præcis de
        // filer, der shipper, frem for en kopi der kan nå at drive fra hinanden.
        .target(name: "BHTestSupport", dependencies: ["BHContracts"]),

        .testTarget(name: "BHContractsTests", dependencies: ["BHContracts", "BHTestSupport"]),
        .testTarget(name: "BHGameCoreTests", dependencies: ["BHGameCore", "BHTestSupport"]),
        .testTarget(name: "BHContentKitTests", dependencies: ["BHContentKit", "BHGameCore", "BHTestSupport"]),
        .testTarget(name: "BHPersistenceTests", dependencies: ["BHPersistence", "BHTestSupport"]),
        .testTarget(
            name: "BHLocationKitTests",
            dependencies: ["BHLocationKit"]
        ),
        .testTarget(
            name: "BHAuthenticationKitTests",
            dependencies: ["BHAuthenticationKit"]
        ),
    ]
)
