# WoWForeverAddons

개인용 WoW Forever 애드온 모음입니다. 다른 PC에서 clone 받아 `AddOns` 폴더로 그대로 쓰기 위한 저장소입니다.

## 설치 (새 PC)

`World of Warcraft\_forever_\Interface\` 폴더에서 아래 명령을 실행합니다. `AddOns` 폴더가 이미 있으면 먼저 다른 이름으로 옮겨 둡니다.

```
git clone --recurse-submodules https://github.com/goodgromit/WoWForeverAddons.git AddOns
```

`--recurse-submodules`를 빼먹고 clone했다면 `AddOns` 폴더에서 아래 명령을 실행합니다. 이걸 하지 않으면 diminfo, autoswitchrep_forever 폴더가 비어 있습니다.

```
git submodule update --init --recursive
```

## 업데이트 (이미 clone한 PC)

```
git pull --recurse-submodules
git submodule update --init --recursive
```

## 포함된 애드온

| 애드온 | 기능 | 제작자 | 버전 | 라이선스 | 비고 |
|---|---|---|---|---|---|
| diminfo | 화면 위 정보 바 (메모리, FPS, 친구, 길드, 소지금, 내구도, 가방, 지역) | Loshine, EK, gromit | F1.0 | - | 서브모듈 → [goodgromit/diminfo](https://github.com/goodgromit/diminfo) |
| autoswitchrep_forever | 평판이 바뀌면 평판 바를 그 평판으로 자동 전환 | Gromit | F1.0 | - | 서브모듈 → [goodgromit/autoswitchrep_forever](https://github.com/goodgromit/autoswitchrep_forever) |
| Aegis_Forever_Instance_Journal | 리테일식 던전 도감과 던전 지도 (Shift+J) | Aegis | 0.40.1 | All Rights Reserved | |
| ForeverFishing | 낚시 보조 (장비, 미끼, 통계, 낚시 도감) | Forever Addon Family | 0.9.224 | 표시 없음 | |
| ForeverLootSparkles | 퀘스트 아이템, 광맥, 약초에 반짝임 효과 항상 표시 | Ashtar Senior | v1.3.1 | GPL-3.0 (`ForeverLootSparkles/LICENSE`) | |
| ForeverNameplateRange | 선택한 적 이름표 왼쪽에 거리 구간 표시 (`/npr`) | Maro | 1.1.0 | 표시 없음 | |
| ForeverQuestMark | 진행 중인 퀘스트와 관련된 대상의 이름표에 퀘스트 아이콘 표시 (`/fqm`) | Ugge Zen | 1.6.1 | MIT (`ForeverQuestMark/LICENSE`) | |
| Leatrix_Maps | 세계 지도 기능 개선 | Leatrix | 1.60.28 | 표시 없음 | |
| RangeDisplay (+ RangeDisplay_Options) | 대상과의 예상 거리 표시 (`/rangedisplay`) | mitch0 | v6.3.7 | Public Domain | |
| RareScanner | 희귀 NPC, 보물, 이벤트를 미니맵에서 찾아 소리와 함께 알림 | maqjav, Maggie Wazosky | 1.60.1.10 | All Rights Reserved | |
| WhatsTraining | 직업 전문가에게 배울 수 있는 기술 표시 | Sveng | 11.4.9 | MIT (`WhatsTraining/LICENSE`) | |

다른 사람이 만든 애드온은 원래 배포본을 그대로 넣은 것이며, 저작권은 각 제작자에게 있습니다.

## 서브모듈 애드온을 수정했을 때

diminfo, autoswitchrep_forever는 각자 저장소에서 수정하고 push합니다. 이 저장소에는 "어느 커밋을 쓰는지"만 기록되므로, 새 커밋을 쓰게 하려면 이 저장소에서 한 번 더 커밋합니다.

```
git add diminfo autoswitchrep_forever
git commit -m "서브모듈 갱신"
git push
```
