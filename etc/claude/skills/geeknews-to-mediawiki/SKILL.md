# GeekNews to MediaWiki Converter

## 개요
news.hada.io (GeekNews) 사이트의 특정 게시물을 MediaWiki 포맷으로 변환하여 파일로 저장하는 스킬입니다.

## 기능
- news.hada.io 게시물 URL을 입력받아 내용 조사
- WebSearch를 통해 관련 정보 수집
- MediaWiki 포맷으로 변환 (HTML 태그 사용)
- 파일로 저장

## 사용법
```
news.hada.io의 게시물 URL (예: https://news.hada.io/topic?id=25503)을 제공
```

## MediaWiki 포맷 구조

### 기본 구조
```mediawiki
게시물 제목

== About ==
* 주요 내용 요약
* 핵심 포인트들

== 주제별 섹션 ==
* 상위 항목
** 하위 항목
** 세부 내용

== See also ==
* [[관련 위키 항목]]
* [[관련 기술]]

== Favorite site ==
* [URL 링크 제목]
* [원본 GeekNews URL]
```

### 텍스트 스타일
- **강조**: `<b>텍스트</b>` (단축 문법 사용 안 함)
- **밑줄**: `<u>텍스트</u>`
- **이탤릭**: `<i>텍스트</i>`
- HTML 태그 사용 원칙

### 섹션 구조
- `== 섹션명 ==`: 2단계 헤딩
- `* `: 1단계 bullet point
- `** `: 2단계 bullet point

### 링크
- 내부 위키 링크: `[[항목명]]`
- 외부 링크: `[URL 제목]`

## 예시 파일
`example.mediawiki` 파일에서 실제 포맷 예시를 확인할 수 있습니다.

## 출력
- 변환된 내용을 `.mediawiki` 확장자 파일로 저장
- 파일명은 게시물 제목이나 ID 기반으로 생성
