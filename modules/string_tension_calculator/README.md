# string_tension_calculator

Самостоятельный модуль с локальным клоном основного калькулятора с [stringtensioncalculator.com](https://www.stringtensioncalculator.com/). Реализация повторяет базовый UI и вычислительную модель исходного сайта, но не включает share-link, query-sync и мультиязычность.

## Источник логики

Логика и данные восстановлены из frontend bundle и sourcemap исходного сайта. Runtime API у сайта нет: наборы струн, формула расчёта, пресеты мензуры и эвристика `Add String` зашиты в клиентский код.

В модуле это зафиксировано локально и без сети:

- datasource: `lib/src/features/calculator/data/datasources/calculator_catalog_datasource.dart`
- repository: `lib/src/features/calculator/data/repositories/local_calculator_repository.dart`
- engine: `lib/src/features/calculator/domain/services/calculator_engine.dart`
- экран: `lib/src/features/calculator/presentation/screens/calculator/calculator_screen.dart`

## Что реализовано в v1

- переключение `Гитара/Бас`
- выбор пресета мензуры
- выбор набора струн
- редактируемая таблица `Мензура / Нота / Калибр / Натяжение / Частота`
- help box по цветовой индикации натяжения
- `Добавить струну`

Публичный API модуля не менялся:

- `lib/string_tension_calculator.dart`
- `lib/src/module/string_tension_calculator_module.dart`

## Локальные данные

В каталог встроены два набора струн:

- `D'Addario XL Nickel Electric Guitar Strings` — 45 позиций
- `Kalium Strings` — 83 позиции

Для каждой позиции хранятся:

- внутренний `id`
- калибр в дюймах
- `unitWeight`
- тип струны `plain` или `wound`

`Kalium Strings` доступен и для гитары, и для баса. `D'Addario XL Nickel Electric Guitar Strings` доступен только для гитары.

## Состояние по умолчанию

Текущее состояние модуля стартует с гитары:

- инструмент: `6-string guitar`
- набор: `D'Addario XL Nickel Electric Guitar Strings`
- мензура: `25.5"`
- строй: `E4 B3 G3 D3 A2 E2`
- id струн: `2 9 14 22 28 36`

Фоновое состояние для переключения на бас:

- инструмент: `4-string bass`
- набор: `Kalium Strings`
- мензура: `34"`
- строй: `G2 D2 A1 E1`
- id струн: `34 41 51 61`

Переключение `Гитара/Бас` просто меняет местами `currentInstrument` и `otherInstrument`, поэтому пользовательский state обоих инструментов сохраняется.

## Пресеты мензуры

Гитара:

- single scale: `24`, `24.75`, `25.5`, `26`, `26.5`, `27`, `27.5`
- multiscale: `25.5-27`, `25-25.5`, `25.5-26.25`, `26.5-28`

Бас:

- single scale: `30`, `34`, `35`, `36`, `37`, `38`, `40`
- multiscale: `34-37`, `37-40`, `34-35.5`, `33.5-35`

Single-scale пресет заполняет одинаковую мензуру всем струнам. Multiscale строит линейную интерполяцию от первой струны к последней с округлением до двух знаков.

## Формула расчёта

Частота вычисляется из scientific note через MIDI-представление:

```text
freq(note) = 440 * 2^((midi - 69) / 12)
```

Натяжение рассчитывается в фунтах:

```text
tension = unitWeight * (2 * scale * freq)^2 / 386.4
```

Округление:

- `tension` — до `2` знаков
- `frequency` — до `1` знака в UI

## Модель действий

Поддерживаются те же базовые операции, что и в web-версии:

- `Instrument toggle` — меняет текущий инструмент
- `Scale preset` — применяет single-scale или multiscale пресет
- `Scale +/-` — меняет мензуру выбранной струны на `0.1"`
- `Note +/-` — меняет ноту на один полутон
- `Gauge +/-` — двигает `physicalStringId` на один шаг внутри активного string set
- `String set change` — ремапит каждую струну по ближайшему `gaugeInches`
- `Add String` — добавляет новую струну по эвристике сайта

Эвристика `Add String`:

1. берётся последняя струна
2. копируется её мензура
3. нота понижается на 5 полутонов
4. внутри текущего набора выбирается струна с минимальной разницей по натяжению относительно предыдущей последней струны

## Цветовая индикация натяжения

Базовые пороги совпадают с исходным сайтом:

- guitar: `19 +/- 11 lbs`
- bass: `40 +/- 15 lbs`

Интерпретация:

- ниже baseline — градиент `yellow -> white`
- выше baseline — градиент `white -> red`

В UI натяжение всегда показывается в `lbs`, частота — в `Hz`, калибр — числом в формате исходного каталога (`0.009`, `0.0085`, `0.110`).

## Архитектура модуля

Структура feature-first:

- `data` — локальный datasource и repository без сети
- `domain` — сущности, формулы и pure-logic engine
- `presentation` — экран, bloc и feature widgets
- `di` — module scope и route scope

DI:

- `StringTensionCalculatorScopeModule` публикует datasource, repository и engine
- `CalculatorModule` публикует `CalculatorBloc`
- `CalculatorRouteScope` поднимает `RouteScope(modules: [CalculatorModule()])`

## Ограничения v1

- нет share-link и compressed query param state
- нет copy-link button
- нет мультиязычности
- нет backend, scraper и live sync
- данные string sets локальные и immutable
