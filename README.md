# hush

> 보낸 지 24시간이 지나면 사라지고, 방을 지우면 모두에게서 사라지는 초대 전용 macOS 메신저

기숙사, 자습실, 카페처럼 옆 사람이 노트북 화면을 쉽게 볼 수 있는 환경을 위해 만든 채팅 앱입니다.
기존 보안 메신저가 **전송 과정**을 보호한다면, hush는 **화면에 보이는 내용**까지 보호합니다.

## 주요 기능

| 기능 | 설명 |
|---|---|
| 24시간 자동 삭제 | 모든 메시지는 보낸 지 24시간이 지나면 서버와 모든 기기에서 삭제 |
| 양쪽 방 삭제 | 방을 삭제하면 모든 멤버의 대화가 함께 삭제 (1:1은 누구나, 그룹은 방장만) |
| 부분 비밀 메시지 | 메시지 안에서 `\|\|비밀\|\|`로 지정한 부분만 가리고, 그 줄을 0.3초 누르고 있는 동안만 표시 |
| IDE 테마 | 멀리서 보면 코드 편집기처럼 보이는 화면 (다크, 라이트) |
| 화면 가리기 | 단축키 한 번으로 진짜 같은 코드 화면으로 전환 |
| 초대 전용 | 초대 링크 또는 코드로 참여, 방장 승인 후 입장, 방마다 다른 닉네임 |
| 종단간 암호화 | 서버는 암호문만 저장 (X25519 키 교환, AES-256-GCM) |
| 메뉴 막대 상주 | 창을 닫아도 실행 유지, 알림에는 내용 없이 "새 메시지"만 표시 |

## 구조

```
hush/
├── app/      # Flutter macOS 클라이언트
├── server/   # Spring Boot 서버
├── infra/    # 로컬 개발 환경 (PostgreSQL, Redis)
└── docs/     # 프로토콜, 데이터 모델 문서
```

## 기술 스택

| 영역 | 기술 |
|---|---|
| 클라이언트 | Flutter (macOS), Riverpod, go_router, drift + SQLCipher, cryptography |
| 서버 | Java 21, Spring Boot 3, Spring WebSocket, Spring Security (OAuth2 Resource Server) |
| 데이터 | PostgreSQL, Flyway, Redis |
| 인증, 푸시 | Firebase Auth, FCM |
| 인프라 | Oracle Cloud, Cloudflare Tunnel, Docker Compose, GitHub Actions |

## 실행

### 로컬 DB

```bash
docker compose -f infra/docker-compose.yml up -d
```

### 서버

```bash
cd server
./gradlew bootRun
```

### 앱

```bash
cd app
flutter pub get
flutter run -d macos
```

## 문서

- [웹소켓 프로토콜](docs/websocket-protocol.md)
- [데이터 모델](docs/data-model.md)

## 진행 상황

- [x] 기획, 화면 설계
- [ ] macOS 네이티브 기능 검증 (화면 캡처 제외, 메뉴 막대, 전역 단축키)
- [ ] 서버: 웹소켓, 인증, 방과 초대 API, 24시간 삭제 스케줄러
- [ ] 앱: IDE 테마 화면, 부분 비밀 문법, 실시간 채팅
- [ ] 종단간 암호화
- [ ] 배포, App Store 출시
