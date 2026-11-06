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

| 애드온 | 제작자 | 라이선스 | 비고 |
|---|---|---|---|
| diminfo | Loshine, EK, gromit | - | 서브모듈 → [goodgromit/diminfo](https://github.com/goodgromit/diminfo) |
| autoswitchrep_forever | Gromit | - | 서브모듈 → [goodgromit/autoswitchrep_forever](https://github.com/goodgromit/autoswitchrep_forever) |
| AtlasLootClassic (+ _Collections, _Crafting, _Data, _DungeonsAndRaids, _Factions, _Options, _PvP) | sliccer | GPL v2 (`AtlasLootClassic/LICENSE`) | |
| AtlasBIStooltips | - | 표시 없음 | AtlasLootClassic 필요 |
| WhatsTraining | Sveng | MIT (`WhatsTraining/LICENSE`) | |
| RangeDisplay (+ RangeDisplay_Options) | mitch0 | Public Domain | |
| ForeverNameplateRange | Maro | 표시 없음 | |

다른 사람이 만든 애드온은 원래 배포본을 그대로 넣은 것이며, 저작권은 각 제작자에게 있습니다.

## 서브모듈 애드온을 수정했을 때

diminfo, autoswitchrep_forever는 각자 저장소에서 수정하고 push합니다. 이 저장소에는 "어느 커밋을 쓰는지"만 기록되므로, 새 커밋을 쓰게 하려면 이 저장소에서 한 번 더 커밋합니다.

```
git add diminfo autoswitchrep_forever
git commit -m "서브모듈 갱신"
git push
```
