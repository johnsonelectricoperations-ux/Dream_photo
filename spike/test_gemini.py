# Gemini Vision API로 사진 분석 가능 여부를 검증하는 스파이크 테스트
import os
import sys
import base64
from pathlib import Path
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

PROMPT = """이 사진을 분석해서 아래 항목을 JSON으로 답해줘.

{
  "description": "한 문장 설명",
  "tags": ["검색에 쓸 수 있는 키워드 목록"],
  "text_in_image": "사진 속 텍스트 (없으면 null)",
  "location_hint": "장소 추정 (없으면 null)",
  "objects": ["주요 사물 목록"]
}"""

def analyze(image_path: str):
    genai.configure(api_key=os.environ["GEMINI_API_KEY"])
    model = genai.GenerativeModel("gemini-2.0-flash")

    path = Path(image_path)
    if not path.exists():
        print(f"파일 없음: {image_path}")
        sys.exit(1)

    with open(path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()

    ext = path.suffix.lower()
    mime = {"jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "webp": "image/webp"}.get(ext.lstrip("."), "image/jpeg")

    response = model.generate_content([
        {"inline_data": {"mime_type": mime, "data": image_data}},
        PROMPT
    ])
    print(response.text)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법: python test_gemini.py <이미지_경로>")
        sys.exit(1)
    analyze(sys.argv[1])
