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
                    "NSPhotoLibraryAddUsageDescription": "모임 사진을 기기에 저장하기 위해 사진첩 접근이 필요합니다.",
                ]
            ),
            sources: [
                "Layered/Sources/**",
            ],
            resources: [
                "Layered/Resources/**",
            ],
            entitlements: "Layered/Layered.entitlements",
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
