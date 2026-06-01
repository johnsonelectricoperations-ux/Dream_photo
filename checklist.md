# Dream Photo — 체크리스트

## Phase 0 — 방향 검증

- [x] 초기 아이디어 정의 (AI 기억 검색)
- [x] 경쟁 앱 분석 (Google Photos, FamilyAlbum, Tidy, Gallery Vault, Mylio 등)
- [x] Gemini Vision API 연결 검증
- [x] 온디바이스 AI 방식 검토 (ML Kit)
- [x] 비용 구조 분석
- [x] 포지셔닝 방향 전환 결정 (검색 → 추억 정리 + 실물)
- [x] 핵심 차별점 확정 (전 연령 / AI 이벤트 앨범 / 한국 인화)
- [x] 문서 업데이트 (vision, positioning, roadmap, context-notes)

## Phase 1 — MVP 준비

- [x] 앱 이름 확정 → **Reel** (com.reel.album)
- [x] MVP 타겟 사용자 1순위 결정 → 전 연령 (가족·커플·친구)
- [x] 인화 제휴 업체 조사 → 스냅스 (사용자 확보 후 제휴 요청)
- [x] Flutter 프로젝트 초기 세팅
- [x] EXIF 파싱 + 이벤트 자동 그룹화 프로토타입 (services/event_grouping_service.dart)
- [x] ML Kit 이미지 라벨링 테스트 (services/ml_kit_service.dart)
- [x] UI/UX 와이어프레임 (screens/01~07 HTML + design.md)
- [x] Riverpod providers 구현 (scan_provider, events_provider)
- [x] 온보딩 화면 — 실제 서비스 연결 + 에러 처리
- [x] 홈 화면 — 다크 헤더, AI 배너, 이벤트 목록, 하단 네비게이션
- [x] 이벤트 상세 화면 — 커버, AI 태그, 사진 그리드, 포토북 FAB
- [x] 검색 화면 — AI 추천 태그, 키워드 검색, 결과 그리드
- [x] 공유 화면 — MVP 플레이스홀더
- [x] 설정 화면 — AI 분석 토글, 알림, 데이터 초기화
- [x] 앱 아이콘 설정 (flutter_launcher_icons + Reel_logo_2.png)
- [ ] flutter pub get 후 앱 실행 확인 (집에서 진행)

## Phase 2 — 수익화

- [ ] 인화 업체 API 연동
- [ ] 포토북 주문 플로우 구현
- [ ] 결제 연동 (인앱결제 or 자체)

## Phase 3 — 공유

- [ ] 링크 공유 (앱 없이 열람)
- [ ] 반응·댓글 기능
