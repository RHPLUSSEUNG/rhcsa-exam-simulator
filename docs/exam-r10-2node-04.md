# exam-r10-2node-04 — 블로그 기반 RHEL 10 실습

[Choo’s blog의 RHCSA 정리](https://www.chooblog.xyz/blog/rhcsa)에 나온
문제 유형을 기존 시뮬레이터의 문제·힌트·참고 풀이·체크포인트 형식으로 구성한
**24문제 연습 시험**입니다. 공식 시험지의 복제본이나 실제 출제를 보장하는 자료가
아닙니다. 문제 문장과 참고 풀이는 이 저장소에 맞춰 새로 작성했습니다.

기본 언어는 한국어이며 영어도 지원합니다. 기존 시험과 채점 라이브러리는 그대로
사용하고, 새 문제 19개와 기존 문제 5개를 조합합니다. 원문의 추가 예제도 포함하되
서로 다른 대안은 아래 기준으로 정리했습니다. 기존 시험의 제한 시간은 변경하지 않습니다.

## 실행

두 VM 모두 RHEL 10과 정상 동작하는 DNF 패키지 원본이 필요합니다. 전체 설치 DVD를
사용하는 경우 해당 버전의 BaseOS·AppStream과 zsh RPM이 있어야 합니다. 인터넷 또는
subscription 저장소가 정상이라면 DVD 없이도 zsh 실습 자원을 준비할 수 있습니다.
Node2에는 OS 디스크 외에 **비어 있는 여분 디스크 한 개**를 준비하십시오.
2 GiB 이상을 권장합니다. 기존 LV, 새 LVM, swap 실습이 이 디스크의 서로 다른
파티션을 함께 사용합니다. 디스크 이름을 `/dev/vdb` 등으로 단정하지 마십시오.
자동 배정 결과는 setup 출력 및 `/var/lib/rhcsa-sim/claims/`에서 확인할 수 있습니다.

양쪽 VM에 이 버전의 시뮬레이터를 설치한 뒤 기존 two-node 절차대로 연결합니다.

```bash
# Node1
sudo rhcsa-sim node-setup --role node1 --peer <node2-ip>
# Node2
sudo rhcsa-sim node-setup --role node2 --peer <node1-ip>
# Node1에서 시험 시작 및 표시
sudo rhcsa-sim --lang ko start exam-r10-2node-04
sudo rhcsa-sim tui
# 영어로 문제/풀이 표시 (진행 상태와 점수 유지)
sudo rhcsa-sim lang en
sudo rhcsa-sim tui
```

`<node1-ip>`와 `<node2-ip>`는 실제 관리망 주소로 바꿉니다. 시험용 네트워크 설정은
별도의 `rhcsa0`에 적용하며 관리망 NIC를 바꾸지 않습니다. Node2 문제는 Node2에서
수행하고 최종 `sudo rhcsa-sim grade`는 Node1에서 실행합니다.
힌트·참고 풀이는 기존 연습 모드의 문제 상세 화면에서 확인합니다.

## 원문 대응표

| 원문 위치 | 노드 / 문제 ID | 구성 |
|---|---|---|
| Node1 1 | node1 / `e2-network` | 고정 IP·게이트웨이·DNS·호스트명, 격리 NIC 사용 |
| Node1 2 | node1 / `e2-repo` | BaseOS·AppStream 저장소 |
| Node1 2 추가 | node1 / `b04-rpm-url` | HTTP URL로 zsh RPM 설치 |
| Node1 3 | node1 / `b04-http` | httpd·페이지·부팅 활성화·영구 방화벽 |
| Node1 4 | node1 / `b04-users` | 계정·보조 그룹·비대화형 셸·비밀번호·sudo |
| Node1 5 및 추가 | node1 / `b04-cron` | 2분 간격 로그·12:30 인사·00:45 정리·cron.allow |
| Node1 6 및 추가 | node1 / `b04-shared` | 그룹 상속 디렉터리·sticky 공유 디렉터리 |
| Node1 7 | node1 / `b04-ntp` | chrony 소스·iburst·서비스 |
| Node1 8 | node1 / `b04-autofs` | public NFS 공유의 주문형 마운트 |
| Node1 9 및 추가 | node1 / `b04-find` | 소유자 검색·복사 및 크기 검색 |
| Node1 10 | node1 / `b04-grep` | 일치하는 행 추출 |
| Node1 11 두 예제 | node1 / `b04-archives` | gzip·bzip2 아카이브 모두 생성 |
| Node1 12 및 추가 | node1 / `b04-acl` | 이름 지정 ACL·finance 기본 ACL |
| Node1 13 및 추가 | node1 / `b04-accounts` | 고정 UID·셸·비밀번호·계정 만료 |
| Node1 14의 ServerB | node2 / `b04-notify` | cron을 매일 07:00 systemd 타이머로 전환 |
| Node1 14 추가 | node2 / `b04-system-check` | 날짜를 추가하는 1분 간격 타이머 |
| Node2 1a | node2 / `root-password` | 콘솔에서 root 비밀번호 복구 |
| Node2 1c 추가 | node2 / `b04-grub-timeout` | GRUB 제한 시간 설정·재생성 |
| Node2 2 | node2 / `e2-repo2` | Node2 저장소 |
| Node2 3 | node2 / `b04-flatpak-user` | student 전용 remote·앱 설치 |
| Node2 4 | node2 / `b04-resize` | 기존 LV와 파일시스템 확대·데이터 보존 |
| Node2 5 | node2 / `b04-lvm` | PE 8 MiB·50 extents·ext4·영구 마운트 |
| Node2 6 | node2 / `b04-swap` | 새 400 MiB swap 파티션·영구 설정 |
| Node2 7 | node2 / `tuning-profile` | 장비가 권장하는 tuned 프로파일 |

## 실습에 맞춘 차이와 채점 한계

- 저장소 주소는 원문의 RHEL 8/9 예시 대신 기존 로컬 저장소 경로를 사용합니다.
  zsh URL은 DVD 또는 활성 DNF 저장소에서 확보한 RPM을 제공하는 로컬 HTTP 주소로
  바꿉니다. zsh 채점은 설치 상태를
  확인하며 설치 명령의 URL 사용 이력까지 증명하지는 않습니다.
- Flatpak은 인터넷 Flathub의 실제 Codium 대신 기존 오프라인 저장소 생성기가 만드는
  **`com.example.CodiumPractice` 실습용 앱**을 사용합니다. 실제 VSCodium 에디터가
  아닙니다. remote 이름 `flatdb`와 `student --user` 범위는 유지하며, system 범위에
  잘못 설치한 경우도 확인합니다. 실제 VSCodium의 앱 ID는
  [Flathub의 `com.vscodium.codium`](https://flathub.org/en/apps/com.vscodium.codium)입니다.
- NFS 서버는 `localhost:/shares/public`으로 제공됩니다. NTP 이름은 로컬 주소로
  연결하며 소스 설정과 서비스만 채점합니다. 외부 NTP와의 실제 동기화는 요구하거나
  검증하지 않습니다.
- 소유자 검색은 루트 파일시스템으로 제한하고 가상 파일시스템과 복사 목적지를
  제외합니다. 크기 검색은 제공된 fixture 트리로 한정합니다. 채점은 준비한 파일과
  디렉터리의 복사 결과를 확인하며 호스트 전체 파일을 전수 비교하지 않습니다.
- 원문의 alex 권한 대안 중 `dnf` NOPASSWD를 사용합니다. 참고 풀이는 필요한 명령만
  위임하지만 요구 권한을 포함하는 더 넓은 sudo 규칙도 통과할 수 있습니다.
  `cron.allow`는 비-root 사용자의 crontab 명령 사용을 제한합니다. root가 등록한
  natasha 작업이 실행되는 것과는 별개입니다.
- finance 기본 ACL의 `r-x`는 새 디렉터리에 상속되지만 일반적으로 mode 0666으로
  생성한 파일에 실행 비트를 새로 부여하지 않습니다. 이 동작을 풀이에서 설명합니다.
- 저장소 관례대로 스토리지 단위는 MiB로 명시합니다. swap을 만드는 과정에서 기존
  LVM이나 swap을 지우거나 `/etc/fstab`을 덮어쓰지 않습니다. 두 타이머는 원문의
  ServerB 지시에 따라 Node2에 배치합니다.
- 원문의 빈 `OnCalendar`, 잘못된 로그 경로와 `daemon-restart`는 요구사항에 맞게
  작성했습니다. Node2 1b의 응급 부팅은 일회성 콘솔 복구 연습이며 영구 채점 항목은
  아닙니다. GRUB 편집 시 `systemd.unit=emergency.target`를 일회성으로 추가하고,
  정상 복귀 후 다음 부팅에 남기지 않습니다. root 비밀번호는 기존 문제처럼 매회
  생성된 문제 본문의 값을 사용합니다.
- 새 `b04-*` 문제는 고정 계정과 공유 자원을 사용하므로 이 시험에 한정합니다.
  `TASK_CROSSNODE=1`로 임의 단일 노드/카테고리 조합에서 제외합니다.

## 검증

안전한 정적·모의 검증:

```bash
python3 -m unittest discover -s tests -p 'test_exam04.py' -v
python3 -m unittest discover -s tests -p 'test_i18n.py' -v
bash tests/test_exam04.sh
bash tests/test_i18n_cli.sh
bash tests/version_test.sh
```

`test_exam04.py`는 구성 계약과 채점 보조 함수의 올바른 설정/틀린 설정을 검사합니다.
`test_exam04.sh`는 Bash 문법, 시험 검색·버전 필터와 참조 무결성을 검사합니다.
실제 디스크나 서비스를 설정하지 않습니다.

**실제 RHEL 10 두 VM에서 setup → 풀이 → grade → 재부팅 → grade → reset은 별도
검증이 필요합니다.** 이 Windows 개발 환경에서 해당 절차의 성공을 확인한 것으로
간주하면 안 됩니다. 검증용 solver는 `tests/solvers/b04-*.sh`에 있으며 관리자 전용
파괴적 실습 스크립트입니다. VM 스냅샷을 만든 뒤 각 노드에서 해당 문제의 solver만
실행하십시오. 참고 풀이에 장치 경로 예시가 있으면 배정된 실제 경로로 바꿉니다.
