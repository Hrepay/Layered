# 겹겹 (Layered)

매주 가족과 함께하는 시간을 만들고 추억을 기록하는 iOS 앱.

## 프로젝트 개요

- **앱 이름**: 겹겹 (Layered)
- **타겟**: 함께 살거나 정기적으로 만나는 가족 단위 (2~6인)
- **핵심 가치**: 가족의 소중함을 일상에서 실천
- **플랫폼**: iOS (SwiftUI) + Firebase
- **프로젝트 관리**: Tuist
- **레포**: `/Users/Hrepay/Layered`

## 핵심 기능

1. **가정(그룹) 생성 & 구성원 관리** — 초대 코드로 가족 초대, 관리자/구성원 역할
2. **주간 플래너 로테이션** — 매주 돌아가며 모임 계획 담당
3. **모임 계획 수립** — 날짜, 장소, 활동 입력 + 선택적 투표
4. **투표** — 장소/활동 후보 투표, 익명 투표 지원
5. **모임 기록 & 히스토리** — 사진, 소감, 별점 기록 + 타임라인

## 코딩 규칙

- **뎁스 있는 화면에는 반드시 뒤로가기 버튼** (onBack 콜백 + chevron.left)
- **텍스트필드 있는 화면의 주요 버튼은 상단 네비게이션 바에 배치** (키보드 가림 방지)
- **컬러 텍스트 절대 금지** — 글자는 검정/회색/흰색만. 컬러는 아이콘·배경·뱃지에만
- **공통 컴포넌트 사용**: AppStyles.swift의 PrimaryButtonStyle, SecondaryButtonStyle, .card(), BadgeView, AvatarView, NavBar, AppTextField, Haptic
- **AppColors 사용**: .blue/.green 등 시스템 컬러 대신 AppColors.primary/secondary/info/warning 사용
- **SF Symbols filled 스타일 우선** (person.3.fill, house.fill 등)
- **모든 버튼에 Haptic.light() 또는 Haptic.medium() 추가**

## 커밋 컨벤션

```
타입: 간단한 설명

상세 설명 (선택, 왜 이렇게 했는지)
```

| 타입 | 용도 |
|------|------|
| `feat` | 새 기능/파일 추가 |
| `fix` | 버그 수정 |
| `refactor` | 동작 변경 없이 코드 개선 |
| `style` | UI/디자인 변경 |
| `chore` | 설정, 빌드, 의존성 |
| `docs` | 문서 |
| `test` | 테스트 |

- 제목은 한글, 50자 이내
- 본문은 선택 — 파일별 변경 이유 등 상세 설명
- 커밋 단위는 "하나의 목적"
- Co-Authored-By 등 자동 서명 추가 금지

## 참고 문서

- **아키텍처 & 데이터 모델**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **디자인 가이드**: [docs/DESIGN_GUIDE.md](docs/DESIGN_GUIDE.md)
- **상세 기획서 (노션)**: https://www.notion.so/Layered-33e2b821dbfd8087afcad06bf229c4bd
- **디자인 시스템 (노션)**: https://www.notion.so/3412b821dbfd812a905fc861a541dac2

## 진행 상황

단계별 진행 체크리스트와 세부 작업 현황은 노션의 [개발 계획 & 진행 상황](https://www.notion.so/3422b821dbfd810f8773d3fddfbf123b) 페이지에서 관리.
