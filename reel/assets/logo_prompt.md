# Reel 앱 로고 제작 가이드

다른 AI 툴에서 로고·아이콘을 만들 때 이 문서의 프롬프트를 그대로 붙여넣어 사용한다.

---

## 앱 정보 요약

| 항목 | 내용 |
|---|---|
| 앱 이름 | **Reel** |
| 슬로건 | 우리의 추억이 저절로 정리됩니다 |
| 컨셉 | 필름 릴(Film Reel) — 소중한 순간을 차곡차곡 감아두는 것 |
| 분위기 | 감성적, 따뜻함, 현대적, 미니멀 |
| 주요 색상 | 배경 `#1A1A2E` (딥 네이비) / 포인트 `#E94560` (따뜻한 레드-핑크) |

---

## 기술 요건 (어느 툴이든 공통)

- **크기:** 512 × 512 px (정사각형)
- **형식:** PNG (투명 배경 또는 단색 배경)
- **모서리:** 앱 아이콘 형태 — iOS/Android 스토어 기준 둥근 모서리(rounded square)
- **배경:** 단색 `#1A1A2E` 또는 그라디언트 (`#1A1A2E` → `#16213E`)
- **여백:** 아이콘 안쪽 사방 10~15% 여백 확보 (플랫폼이 자동으로 자르기 때문)
- **텍스트 없음:** 앱 이름 "Reel" 글자는 로고 안에 넣지 않아도 됨 (스토어 등록 시 별도 입력)

---

## 디자인 방향 (3가지 컨셉 중 선택)

### 컨셉 A — 필름 릴 (추천)
필름 릴 모양을 모던하게 단순화한 아이콘.
스프로킷 홀(sprocket holes)이 있는 원형 릴 구조, 중앙 허브, 스포크(spoke).
레드-핑크 포인트 색상을 한 곳에 집중 사용.

### 컨셉 B — 카메라 셔터 + 하트
카메라 조리개(aperture) 블레이드가 하트를 이루는 형태.
"사진 = 추억" 메타포를 직접 표현.

### 컨셉 C — 폴라로이드 필름
폴라로이드 사진 한 장이 약간 기울어진 형태.
사진 안에 산, 가족, 노을 같은 실루엣.
친근하고 따뜻한 느낌.

---

## ChatGPT (DALL-E) 프롬프트

아래를 ChatGPT 채팅창에 그대로 붙여넣는다.

```
Create a mobile app icon for an app called "Reel" — an AI-powered photo memory album app.

Style requirements:
- Minimalist, modern, clean
- Warm and emotional feel, not cold or tech-heavy
- Flat design with subtle depth (soft shadows or gentle gradients allowed)

Visual concept: A stylized film reel icon
- Circular film reel shape with 6–8 small sprocket holes around the outer ring
- 3 spokes connecting the outer ring to the center hub
- Center hub can have a small heart shape or a glowing dot
- One or two elements highlighted in warm red-pink (#E94560)
- Overall structure in semi-transparent white on a deep navy background

Colors:
- Background: deep navy #1A1A2E (or gradient from #1A1A2E to #16213E)
- Accent: warm red-pink #E94560 (use sparingly — just 1–2 key elements)
- Reel structure: white at 15–25% opacity

Format: 512×512px, square with rounded corners (like an iOS app icon), PNG
No text. No letters. Just the icon mark.

Make it feel like a premium, emotional photo app — similar in quality to Unfold, VSCO, or Darkroom.
```

---

## Midjourney 프롬프트

Discord에서 `/imagine` 명령어 뒤에 붙여넣는다.

### 버전 1 — 필름 릴 (심플)
```
minimalist app icon, film reel symbol, deep navy background #1A1A2E, warm pink-red accent #E94560, clean vector style, sprocket holes, 3 spokes, center glow, rounded square format, premium photo app aesthetic, flat design, soft gradient, 512x512 --v 6 --ar 1:1 --style raw
```

### 버전 2 — 감성적
```
elegant mobile app icon, film reel with heart center, dark navy #1A1A2E background, rose red #E94560 highlight, memories and nostalgia theme, ultra clean minimalist design, subtle inner glow, premium UI icon quality, behance worthy, rounded square --v 6 --ar 1:1
```

### 버전 3 — 카메라 셔터 + 하트 (컨셉 B)
```
app icon design, camera aperture blades forming a heart shape, deep navy dark background, warm pinkish-red accent color, modern flat vector, emotional photo memory app, clean minimal icon, rounded square canvas --v 6 --ar 1:1 --style raw
```

---

## Adobe Firefly 프롬프트

Adobe Express 또는 Firefly 웹사이트에서 사용한다.

```
Mobile app icon for a photo memory app.
Subject: Film reel (circular, with sprocket holes and 3 spokes)
Style: Modern flat design, minimalist, premium
Colors: Dark navy blue background (#1A1A2E), warm coral-pink accent (#E94560)
Mood: Warm, nostalgic, emotional, clean
Format: Square icon, rounded corners
No text or letters included
```

---

## Canva AI (Text to Image) 프롬프트

Canva → 앱 → AI 이미지 생성 탭에서 사용한다.

```
App icon design: a simple film reel on a dark navy background. The reel has clean circular sprocket holes around the edge and 3 spokes. One element highlighted in warm pink-red. Minimalist, modern, premium feel. Square format with rounded corners. No text.
```

---

## 로고 피드백 체크리스트

만들어진 로고를 평가할 때 아래 기준으로 확인한다.

- [ ] 32×32px로 줄여도 형태가 보이는가
- [ ] 흰색 배경에 올려도 이상하지 않은가
- [ ] 네이비·레드핑크 색상이 지켜졌는가
- [ ] 다른 사진 앱(VSCO, Google Photos 등)과 충분히 구별되는가
- [ ] "따뜻하고 감성적인" 느낌이 드는가
- [ ] 기술적·차가운 느낌이 나지 않는가

---

## 최종 파일 납품 형식

| 용도 | 사양 |
|---|---|
| 구글 플레이 스토어 | 512×512px PNG, 32비트, 투명 배경 없음 |
| 앱 내 아이콘 (Flutter) | 1024×1024px PNG → Flutter `flutter_launcher_icons` 패키지가 자동 리사이즈 |
| 스플래시 화면 로고 | 배경 없는 투명 PNG, 최소 512×512px |
| 웹/마케팅용 | SVG 또는 2048×2048px PNG |

Flutter 프로젝트에 아이콘 적용하는 방법은 별도로 안내받을 것.
