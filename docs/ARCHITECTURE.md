# 아키텍처 & 데이터 모델

## 아키텍처: Clean Architecture + MVVM

```
Layered/Sources/
├── App/                    # 앱 진입점 (LayeredApp, AppState, RootView)
├── Data/
│   ├── Mock/               # 목 데이터 & 목 Repository (개발용)
│   └── Repository/         # Firebase Repository 구현체
├── Domain/
│   ├── Model/              # Entity (User, Family, Member, Meeting, Poll, MeetingRecord)
│   └── Repository/         # Repository 프로토콜 (인터페이스)
├── Presentation/
│   ├── Auth/               # 스플래시, 온보딩, 로그인
│   ├── Family/             # 가정 생성/참여, 구성원 관리
│   ├── Home/               # 홈, 탭바
│   ├── Meeting/            # 모임 CRUD
│   ├── Poll/               # 투표 생성/참여/결과
│   ├── Record/             # 모임 기록, 히스토리
│   ├── Settings/           # 설정, 프로필, 알림, 계정
│   └── Common/             # 공통 컴포넌트 (Loading, Toast, EmptyState, ColorPalette)
└── Util/                   # AppColors, AppStyles (디자인 토큰 & 공통 스타일)
```

## 설계 원칙

- **Domain이 Firebase를 모름** — Repository 프로토콜로 추상화
- **ViewModel이 View↔UseCase 연결** — @Observable 바인딩
- **데이터 흐름**: View → ViewModel → Repository(프로토콜) → DataSource(Firebase)
- **목 → 실제 교체**: Mock Repository → Firebase Repository로 DI 전환

## 화면 전환 구조

- `AppState` — authState enum으로 전체 흐름 관리 (splash → onboarding → login → familySetup → home)
- `RootView` — AppState에 따라 화면 분기
- `MainTabView` — 홈/히스토리/설정 탭바
- 하위 화면은 `fullScreenCover`로 전환

## Firestore 컬렉션 구조

```
families/{familyId}
  ├── members/{memberId}
  ├── meetings/{meetingId}
  │     ├── polls/{pollId}
  │     └── records/{recordId}

users/{uid}
```

## 데이터 모델

### User — users/{uid}
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | Firebase Auth UID |
| name | String | 표시 이름 |
| profileImageURL | String? | 프로필 사진 URL |
| familyId | String? | 소속 가정 ID (nil이면 미가입) |
| createdAt | Date | 가입일 |
| agreedTermsAt | Date? | 약관 동의 시각 |
| agreedTermsVersion | String? | 동의한 약관 버전 (예: "1.0") |
| marketingConsent | Bool? | 마케팅 정보 수신 동의 여부 |

> Firestore 전용 필드(Swift 모델엔 없음): `fcmToken`, `notificationsEnabled`, `notifyPlannerReminder`, `notifyMeetingCreated`

### Family — families/{familyId}
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 문서 ID |
| name | String | 가정 이름 |
| inviteCode | String | 6자리 초대 코드 |
| inviteCodeExpiresAt | Date | 초대 코드 만료 시간 |
| adminId | String | 관리자 UID |
| memberCount | Int | 현재 구성원 수 |
| currentPlannerIndex | Int | 현재 플래너 순번 |
| rotationDay | Int | 로테이션 기준요일 (1=월~7=일) |
| rotationMode | String | 로테이션 방식 ("auto" \| "manual") |
| createdAt | Date | 생성일 |

### Member — families/{familyId}/members/{memberId}
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | Firebase Auth UID |
| name | String | 표시 이름 |
| profileImageURL | String? | 프로필 사진 |
| role | enum | admin / member |
| rotationOrder | Int | 플래너 순서 (0부터) |
| joinedAt | Date | 가정 참여일 |

### Meeting — families/{familyId}/meetings/{meetingId}
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 문서 ID |
| plannerId | String | 플래너 UID |
| plannerName | String | 플래너 이름 (비정규화) |
| meetingDate | Date | 모임 날짜/시간 |
| place | String | 장소명 |
| placeLatitude | Double? | 위도 |
| placeLongitude | Double? | 경도 |
| placeURL | String? | 장소 링크 (네이버지도/카카오맵 등) |
| activity | String? | 활동 내용 (프리셋 다중 선택은 ", "로 결합) |
| status | enum | planning / confirmed / completed / cancelled |
| hasPoll | Bool | 투표 존재 여부 |
| createdAt | Date | 생성일 |
| updatedAt | Date | 수정일 |

### Poll — meetings/{meetingId}/polls/{pollId}
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 문서 ID |
| question | String | 투표 질문 |
| isAnonymous | Bool | 익명 투표 여부 |
| allowMultiple | Bool | 복수 선택 가능 |
| options | [PollOption] | 선택지 배열 (문서 내 배열) |
| createdAt | Date | 생성일 |

> **참고**: 초기 기획에 있던 `deadline`/`status` 필드는 Phase 3에서 "투표 마감 기능 불필요"로 판단되어 제거됨.

### PollOption — Poll.options 배열 내 객체
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 선택지 ID |
| title | String | 선택지 제목 |
| description | String? | 설명 |
| imageURL | String? | 선택지 이미지 URL (선택) |
| voterIds | [String] | 투표자 UID 목록 (익명시 빈 배열) |
| voteCount | Int | 투표 수 |

### MeetingRecord — meetings/{meetingId}/records/{recordId}
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 문서 ID |
| memberId | String | 작성자 UID |
| memberName | String | 작성자 이름 (비정규화) |
| photos | [String] | 사진 URL (최대 3장) |
| comment | String | 한 줄 소감 (최대 1000자) |
| rating | Int | 별점 1~5 |
| createdAt | Date | 생성일 |
| updatedAt | Date | 수정일 |

## 설계 포인트

- **비정규화**: plannerName, memberName — 매번 조인 없이 UI 바로 표시. 이름 변경 시 관련 문서 업데이트 필요
- **PollOption 배열 내장**: 선택지 최대 4개라 서브컬렉션보다 문서 1개에 배열이 성능적 유리
- **익명 투표**: isAnonymous=true면 voterIds 저장 안 하고 voteCount만 증가
