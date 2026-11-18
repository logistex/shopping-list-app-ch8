---
name: shop-review
description: Use when the user asks to review, check, or audit the shopping list app (index.html) or other code in this project for bugs, security issues, or readability, or runs /shop-review. 쇼핑 리스트 앱 코드 리뷰, 점검, 검토 요청 시 사용.
argument-hint: "[검토할 파일 경로 (생략하면 index.html)]"
allowed-tools: Read, Grep, Glob
---

# shop-review

쇼핑 리스트 앱 코드를 **읽기만 해서** 버그 · 보안 · 읽기 쉬움 세 갈래로 문제와 고칠 방법을 보고한다.

## 원칙: 읽기 전용

이 리뷰가 하는 일은 파일을 읽고 보고서를 쓰는 것뿐이다.

- 쓰는 도구: `Read`, `Grep`, `Glob`
- 고칠 방법은 보고서 안의 코드 조각으로만 제시한다. 실제 파일은 그대로 둔다.
- 리뷰가 끝난 뒤 사용자가 "고쳐줘"라고 따로 요청하면, 그때 새 작업으로 수정한다.

## 대상

- `$ARGUMENTS`가 있으면 그 파일(들)을 검토한다.
- 없으면 프로젝트 루트의 `index.html`(HTML · CSS · 인라인 JS가 한 파일에 있음)을 검토한다.
- 파일을 처음부터 끝까지 읽은 뒤 판단한다. 줄 번호는 실제로 읽은 내용에서 가져온다.

## 무엇을 볼까

### 1. 버그
- `localStorage`에서 읽은 값이 배열이 아니거나 항목 모양이 다를 때 (`items.filter` 등에서 오류)
- id 생성 방식의 충돌 가능성, id 타입(숫자/문자열) 불일치
- 상태 변경 후 `save()` / `render()` 누락, 이벤트 리스너 중복 등록
- 빈 입력·공백·아주 긴 텍스트 처리, 경계 상황(0개, 전부 완료)

### 2. 보안
- 사용자 입력이 `innerHTML`, `insertAdjacentHTML`, 템플릿 문자열 HTML로 들어가는 곳 (XSS)
- `textContent` 대신 HTML 파싱 API를 쓰는 곳
- `localStorage` 값을 검증 없이 신뢰하는 곳 (사용자가 조작 가능)
- 외부 스크립트·CDN, `eval` / `new Function`, 인라인 이벤트 핸들러 속성

### 3. 읽기 쉬움
- 한 함수가 너무 많은 일을 하는 곳 (예: `render`가 목록 그리기와 요약 갱신을 함께 함)
- 반복되는 `save(); render();` 패턴, 매직 값, 모호한 이름
- 주석이 필요한데 없는 곳 / 코드와 맞지 않는 주석
- CSS 변수·클래스 이름의 일관성

문제가 없는 갈래는 억지로 채우지 말고 "발견된 문제 없음"이라고 쓴다.

## 보고서 형식

다음 순서와 모양 그대로 출력한다.

````markdown
# shop-review 결과: <파일 이름>

## 요약
버그 N건 · 보안 N건 · 읽기 쉬움 N건 — 가장 먼저 고칠 것: <한 줄>

## 🐞 버그
### [높음|중간|낮음] <문제 제목> — `index.html:줄번호`
- **문제:** 무엇이 잘못됐는지 한두 문장
- **재현/영향:** 어떤 상황에서 어떤 결과가 나는지
- **고칠 방법:**
  ```js
  // 바꾼 코드 조각
  ```

## 🔒 보안
(같은 모양)

## 📖 읽기 쉬움
(같은 모양)
````

- 심각도: 높음(데이터 손실·앱 멈춤·XSS) / 중간(특정 조건에서 오동작) / 낮음(개선 권장)
- 각 갈래 안에서는 심각도 높은 순으로 나열한다.
- 확실하지 않은 항목은 제목 끝에 `(추정)`을 붙이고, 왜 확신하지 못하는지 적는다.
