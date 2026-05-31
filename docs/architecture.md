# Dream Photo Architecture

## Overview

Dream Photo는 사용자의 사진과 영상을
기억 검색 가능한 데이터로 변환하는 플랫폼이다.

핵심 목표는 다음과 같다.

- 빠른 검색
- 높은 정확도
- 개인정보 보호
- 글로벌 확장성

---

# Architecture Principles

## Privacy First

사용자 사진은 가능한 한 기기 내에서 처리한다.

Dream Photo는 사진 저장 서비스가 아니라
기억 검색 서비스다.

사용자 신뢰가 가장 중요하다.

---

## Search First

Dream Photo의 중심은 갤러리가 아니다.

검색이다.

모든 데이터 구조는 검색 최적화를 기준으로 설계한다.

---

## AI Assisted

사용자가 태그를 직접 입력하지 않아도 된다.

AI가 자동으로 분석한다.

---

# High Level Architecture

Mobile App

↓

Photo Scanner

↓

AI Analysis

↓

Memory Database

↓

Search Engine

↓

User

---

# Client

## Mobile

Framework

Flutter

이유

- Android
- iOS 동시 지원
- 개발 속도
- 유지보수 효율

---

# Local Database

SQLite

초기 MVP 사용

저장 데이터

- 사진 ID
- 파일 경로
- OCR 결과
- 태그
- AI 설명
- 위치
- 이벤트 ID

---

# AI Layer

## Phase 1

Cloud AI

사용 목적

- 빠른 MVP 검증

후보

- Gemini Vision
- OpenAI Vision

---

## Phase 2

On-device AI

목표

사진을 외부 서버로 보내지 않음

후보

- Gemma
- Phi
- Qwen

---

# OCR

목적

사진 속 텍스트 검색

예시

- 차번호
- 제품 모델명
- 명함
- 영수증

후보

Google ML Kit

장점

- 무료
- 모바일 지원
- 오프라인 가능

---

# Image Understanding

AI가 분석하는 정보

- 사물
- 장소
- 문서
- 차량
- 음식
- 여행

예시

사진

↓

"흰색 SUV 차량"

↓

자동차 태그 생성

---

# Event Engine

Dream Photo의 핵심 기능

사진들을 기억 단위로 묶는다.

예시

강릉 여행

포함

- 바다
- 음식
- 숙소
- 카페

---

자동 생성 기준

- 시간
- 위치
- 객체
- 사용자 행동

---

# Search Engine

사용자 입력

강릉

차번호

불량품

자동차 수리

↓

관련 기억 검색

↓

관련 사진 표시

---

# Future Architecture

## Cloud Sync

선택 기능

사용자가 원할 경우만 사용

---

## Video Analysis

영상 프레임 분석

---

## Memory Assistant

AI 기반 기억 비서

예시

"내 차번호 알려줘"

"작년에 제주도 갔었나?"

---

# Security

기본 원칙

사진 원본은 사용자 소유

Dream Photo는 사용자의 기억을 돕는다.

사진을 수집하지 않는다.

---

# MVP Technology Stack

Frontend

- Flutter

Database

- SQLite

OCR

- Google ML Kit

AI

- Gemini Vision

Search

- SQLite FTS

Version Control

- GitHub

Repository

Dream_photo
