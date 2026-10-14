# 한국어 현지화 구조 및 검증

## 사전 분석

| 대상 | 기존 위치 / 연결 |
|---|---|
| 시험 선택 | `bin/rhcsa-sim`의 `list`, `start`, `practice`, `mock`; `exams/*.list` |
| 문제 제목 | 각 `tasks/<id>/meta.sh`의 `TASK_TITLE` |
| 본문·요구사항 | `tasks/<id>/prompt.txt` |
| 모범 풀이·해설 | `tasks/<id>/solution.md` |
| 힌트 | `lib/params.sh`의 `render_hint`: 풀이 제목, 주석 및 명령에서 생성 |
| 세션 및 무작위 값 | `session.json`, `params/<id>.env`; `render_prompt`/`render_solution`으로 치환 |
| 화면 | `tui/exam_tui.py`(curses), `tui/exam_web.py`(표준 라이브러리 HTTP 서버) |
| 채점 | 문제 ID로 `tasks/<id>/grade.sh` 실행; `lib/grade-lib.sh`가 JSONL 결과 출력 |
| 결과 집계 | `report/report.py`의 `grade`; CLI의 두 노드 결과 합산 |

18개 시험 목록은 총 281개 문제 템플릿을 참조합니다. 실제 RHEL 버전에 맞는 시험과
문제만 선택하는 기존 필터를 유지했습니다. 목록뿐 아니라 분야별 연습 등에서 사용하는
281개 전체 문제를 번역 대상으로 삼았습니다. 별도 `hint.txt`는 없으므로 기존 생성
힌트의 접근 방법, 단계, 명령 목록 및 문서 안내를 한국어 카탈로그에 포함했습니다.

## 표시 계층

`lib/i18n.py`가 언어 결정, 카탈로그 조회, 영어 대체, 저장된 값 치환 및 유니코드
표시 폭 계산을 제공합니다. `lib/i18n.sh`는 CLI의 사용자 표시 메시지만 연결합니다.
데이터를 출력하는 기존 `echo`, `printf`, `read` 내장 명령을 덮어쓰지 않습니다.

수정한 파일: `README.md`, `bin/rhcsa-sim`, `install.sh`, `report/report.py`,
`tui/exam_tui.py`, `tui/exam_web.py`.
추가한 파일: `lib/i18n.py`, `lib/i18n.sh`, `docs/LOCALIZATION.md`,
`tests/test_i18n.py`, `tests/test_i18n_cli.sh` 및 아래 다섯 카탈로그.

`locales/ko/` 구성:

- `tasks.json`: ID별 제목, 본문, 풀이, 힌트. 영어 원본 파일은 유지합니다.
- `messages.json`: UI·CLI의 표시 문자열.
- `javascript.json`: 브라우저의 타이머 및 확인 대화상자 문구. VM 동작 ID는 유지합니다.
- `patterns.json`: 문제 번호·남은 시간 등 값이 포함된 표시 형식.
- `checkpoints.json`: 영어 채점 설명 템플릿의 한국어 표시. `$VAR` 등 값은 보존합니다.

언어 선택은 `--lang`, `RHCSA_LANG`, 상태 디렉터리의 `language`, `ko` 순서입니다.
브라우저의 언어 변경 API는 `language`만 쓰며 `session.json`, 표시 기록, 점수 및
무작위 값 파일을 변경하지 않습니다. TUI의 `l`도 같은 설정을 저장합니다.
누락된 번역과 새 버전 전용 파일은 해당 영어 원문으로 대체합니다.

다른 언어 추가 시 `lib/i18n.py`의 `LANGUAGE_NAMES`에 코드와 표시 이름을 추가하고
`locales/<code>/`에 같은 형식의 카탈로그를 작성하십시오. CLI 검증, Python 옵션,
브라우저 선택 목록 및 TUI 전환 순서는 이 언어 목록을 사용합니다.

## 보호한 요소

문제 ID, 분야 ID, 배점, 시험 목록, 제한 시간, 매개변수 생성, 채점 조건과 집계 계산을
변경하지 않았습니다. `tasks/`의 원본·setup·grade·teardown·params 파일과
`lib/common.sh`, `lib/params.sh`, `lib/grade-lib.sh`, `lib/nodes.sh`,
`lib/storage-prep.sh`는 변경하지 않았습니다. 설치 스크립트는 `locales` 복사 대상만
추가했습니다. 라이선스 및 저작권을 유지하고 의존성을 추가하지 않았습니다.

풀이의 실행 가능한 코드 블록은 영어 원본과 동일합니다. 번역된 매개변수는 기존
세션 파일에서 읽고 재생성하지 않습니다. 두 노드 화면은 이미 가져온 영어 본문에서
상대 노드의 실제 치환 값을 복구하여 본문·풀이에 동일하게 적용합니다.
`check`의 텍스트 완료 표시는 TUI에서 영어 출력으로 판정한 뒤 표시만 번역합니다.
채점 JSON/JSONL과 보고서 JSON은 원래 필드와 영어 메타데이터를 유지합니다.

## 검증 방법 및 한계

```bash
python3 -m unittest discover -s tests -p test_i18n.py -v
bash tests/test_i18n_cli.sh
bash tests/version_test.sh
bash -n bin/rhcsa-sim
bash -n lib/i18n.sh
bash -n install.sh
python3 -m compileall -q lib/i18n.py tui report
```

자동 검증은 전체 문제/시험 목록의 번역 존재, 코드 블록 동일성, 본문의 숫자·경로·
명령·치환 변수 보존, 언어 우선순위 및 영어 대체, 합성 채점 데이터의 집계 동일성,
HTTP 언어 변경 및 상태 보존, 한글 표시 폭, 작은 화면의 TUI 선택·전환을 검사합니다.
CLI 테스트는 임시 상태에서 도움말·언어 설정·힌트·풀이를 실행하며 시스템 구성은
수행하지 않습니다. 실제 RHEL에서 새 시험을 시작하거나 저장소·사용자 등을 설정하지
않아도 실행할 수 있습니다.

Windows Git Bash에는 `/etc/os-release`가 없으므로 기존 버전 테스트의 첫 실행은
그 환경 전제로 한 항목이 실패했습니다. `VERSION_ID=9`를 테스트 환경에 제공한
재실행에서는 통과했습니다. 이는 RHEL 부팅·서비스·저장소의 실행 검증을 의미하지
않습니다. Windows의 Python 실행 별칭이 비활성인 경우 CLI 테스트에
`RHCSA_TEST_PYTHON`으로 실제 Python 실행 파일을 지정할 수 있습니다.

실제 RHEL 9/10 VM에서 시험 시작·종료, 재부팅 후 영구 적용 채점, 두 노드 SSH 및
설치 업데이트를 실행한 검증은 별도로 필요합니다. 실제 터미널/브라우저에서 글꼴과
화면을 눈으로 확인한 검증도 별도입니다. 외부 프로그램의 원시 진단 및 새 문자열의
번역 누락은 영어로 표시됩니다. 전체 문제 카탈로그 281/281은 자동 검사하며 UI의
모든 실행 분기를 실제 환경에서 검증했다고 주장하지 않습니다.
