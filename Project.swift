import ProjectDescription

let project = Project(
    name: "Layered",
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "BBVZV8T99P",
            "CODE_SIGN_STYLE": "Automatic",
            "OTHER_LDFLAGS": "-ObjC",
        ]
    ),
    targets: [
        .target(
            name: "Layered",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Layered",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: [
                "Layered/Sources/**",
            ],
            resources: [
                "Layered/Resources/**",
            ],
            dependencies: [
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage"),
            ]
        ),
        .target(
            name: "LayeredTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.LayeredTests",
            infoPlist: .default,
            buildableFolders: [
                "Layered/Tests"
            ],
            dependencies: [.target(name: "Layered")]
        ),
    ]
)
