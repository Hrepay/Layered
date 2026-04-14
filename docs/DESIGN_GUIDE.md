# 디자인 가이드

레퍼런스: 당근 앱 스타일. 따뜻하고 부드러운 가족 앱. 미니멀하지만 정감 있는 느낌.

## 핵심 원칙

- **여백 넓게** — 콘텐츠 사이 충분한 숨 공간
- **둥글둥글** — cornerRadius 16~20 (카드), 14 (입력 필드), Capsule (뱃지)
- **플랫 디자인** — 그림자 최소화, 배경색 차이로 영역 구분
- **컬러 텍스트 절대 금지** — 글자는 검정(.primary)/회색(.secondary)/흰색만
- **컬러는 아이콘·배경·뱃지에만** 사용
- **SF Symbols filled 스타일** 우선
- **모든 버튼에 햅틱** — Haptic.light() / Haptic.medium()
- **터치 영역 44pt 이상**

## 컬러 팔레트

| 이름 | HEX | 코드 | 용도 |
|------|-----|------|------|
| Primary | #FF9472 | `AppColors.primary` | 메인 버튼, 강조 아이콘, 탭바 활성 |
| Primary Light | #FFB99A | `AppColors.primaryLight` | 호버, 토글 ON |
| Primary Subtle | #FFF0E8 | `AppColors.primarySubtle` | 연한 배경, 선택 상태, 아바타 |
| Olive | #8B9E6B | `AppColors.secondary` | 확정/성공 뱃지 |
| Sky | #6BB5C9 | `AppColors.info` | 투표, 정보 뱃지 |
| Warning | #F5A623 | `AppColors.warning` | 계획 중, 리마인드 |
| Error | System Red | — | 삭제, 에러 |

## 공통 컴포넌트 (AppStyles.swift)

| 컴포넌트 | 사용법 | 용도 |
|---------|--------|------|
| `PrimaryButtonStyle` | `.buttonStyle(PrimaryButtonStyle())` | 메인 CTA 버튼 |
| `SecondaryButtonStyle` | `.buttonStyle(SecondaryButtonStyle())` | 서브 버튼 |
| `.card()` | `.card()` / `.card(highlighted: true)` | 카드 배경 래핑 |
| `.tappableCard()` | `.tappableCard()` | 탭 가능한 카드 (scaleEffect) |
| `BadgeView` | `BadgeView(text:, color:)` | 상태 뱃지 (Capsule) |
| `AvatarView` | `AvatarView(name:, size:)` | 프로필 아바타 (32/44/80pt) |
| `NavBar` | `NavBar(title:, backAction:, trailingText:, ...)` | 커스텀 네비게이션 바 |
| `AppTextField` | `AppTextField(placeholder:, text:)` | 입력 필드 (포커스 시 피치 테두리) |
| `Haptic.light()` | `Haptic.light()` | 가벼운 햅틱 |

## 뱃지 컬러 규칙

| 상태 | 색상 |
|------|------|
| 확정 | `AppColors.secondary` (올리브) |
| 계획 중 | `AppColors.warning` (앰버) |
| 투표 진행 | `AppColors.info` (스카이) |
| 관리자 | `AppColors.primary` (피치) |
| 완료 | `.gray` |

## 네비게이션 바

- **Large Title**: 홈, 히스토리, 설정 (메인 탭)
- **Inline**: 하위 화면 (NavBar 컴포넌트 사용)
- **뒤로가기**: chevron.left, 좌측
- **액션 버튼**: 우측 (등록, 저장 등), disabled 시 .secondary 색

## 스페이싱

- 8pt 그리드 기본
- 카드 내부 패딩: 16px
- 카드 간 간격: 12~16px
- 화면 좌우 여백: 20px
- 섹션 간 간격: 24px

## 그림자

- **기본**: 사용 안 함 (플랫)
- **플로팅 요소만**: 토스트, 바텀시트 → `.shadow(color: .black.opacity(0.08), radius: 12, y: 4)`
- **카드에 절대 그림자 넣지 않기**

## 이미지/사진

- 비율: 1:1 정사각
- 모서리: cornerRadius 12
- 플레이스홀더: tertiarySystemFill + photo 아이콘
- 리사이징: 업로드 전 최대 1080px, JPEG 80%

## DO & DON'T

| DO | DON'T |
|----|-------|
| 카드 배경으로 영역 구분 | 선(border)으로 구분 |
| 둥근 모서리 (16~20) | 날카로운 직각 |
| 카드 내부 여백 넓게 (16px) | 콘텐츠 빽빽하게 |
| 뱃지는 컬러 배경 + 흰 글씨 | 뱃지 글씨에 컬러 |
| 강조는 font weight(bold) | 강조를 컬러로 |
| 아이콘에 컬러 | 본문 텍스트에 컬러 |
| 빈 상태에 일러스트 + 안내 | 빈 화면 방치 |
| 탭 시 시각+촉각 피드백 | 아무 반응 없이 전환 |
| 부드러운 spring 애니메이션 | 즉시 전환 |
| 상태별 UI 변화 (로딩→콘텐츠→에러) | 갑자기 표시 |
