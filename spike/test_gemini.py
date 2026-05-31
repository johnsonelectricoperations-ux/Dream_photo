# Gemini Vision API로 사진 분석 가능 여부를 검증하는 스파이크 테스트
import os
import sys
import base64
import requests
import json
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

MODEL = "gemini-2.5-flash"
PROMPT = """이 사진을 분석해서 아래 항목을 JSON으로만 답해줘. 다른 설명 없이 JSON만.

{
  "description": "한 문장 설명",
  "tags": ["검색에 쓸 수 있는 키워드 목록"],
  "text_in_image": "사진 속 텍스트 (없으면 null)",
  "location_hint": "장소 추정 (없으면 null)",
  "objects": ["주요 사물 목록"]
}"""

def analyze(image_path: str):
    path = Path(image_path)
    if not path.exists():
        print(f"파일 없음: {image_path}")
        sys.exit(1)

    ext = path.suffix.lower().lstrip(".")
    mime = {"jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "webp": "image/webp"}.get(ext, "image/jpeg")

    with open(path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()

    key = os.environ["GEMINI_API_KEY"]
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={key}"
    body = {
        "contents": [{
            "parts": [
                {"inline_data": {"mime_type": mime, "data": image_data}},
                {"text": PROMPT}
            ]
        }]
    }

    r = requests.post(url, json=body)
    if r.status_code != 200:
        print(f"API 오류 {r.status_code}: {r.text}")
        sys.exit(1)

    text = r.json()["candidates"][0]["content"]["parts"][0]["text"]
    text = text.strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()
    result = json.loads(text)
    print(json.dumps(result, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법: python spike/test_gemini.py <이미지_경로>")
        sys.exit(1)
    analyze(sys.argv[1])
