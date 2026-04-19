import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_instruments/my_instruments.dart';
import 'package:string_tension_calculator/src/features/calculator/data/datasources/calculator_catalog_datasource.dart';
import 'package:string_tension_calculator/src/features/calculator/data/mappers/saved_instrument_mapper.dart';
import 'package:string_tension_calculator/src/features/calculator/data/repositories/local_calculator_repository.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/entities/entities.dart';
import 'package:string_tension_calculator/src/features/calculator/domain/services/calculator_engine.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_bloc.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_event.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/bloc/calculator_state.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/calculator_mode.dart';
import 'package:string_tension_calculator/src/features/calculator/presentation/screens/calculator/models/save_instrument_submission.dart';

import '../test_helpers/fake_my_instruments_repository.dart';

void main() {
  const dataSource = CalculatorCatalogDataSource();
  const repository = LocalCalculatorRepository(dataSource: dataSource);
  const engine = CalculatorEngine(repository: repository);
  const mapper = SavedInstrumentMapper(repository: repository);

  blocTest<CalculatorBloc, CalculatorState>(
    'starts with manual guitar mode and empty saved instruments',
    build: () => CalculatorBloc(
      repository: repository,
      engine: engine,
      myInstrumentsRepository: FakeMyInstrumentsRepository(),
      savedInstrumentMapper: mapper,
    ),
    act: (bloc) => bloc.add(const CalculatorStarted()),
    expect: () => [
      isA<CalculatorReady>()
          .having((state) => state.selectedMode, 'mode', CalculatorMode.guitar)
          .having(
            (state) => state.guitarDraft.type,
            'guitar draft type',
            InstrumentType.guitar,
          )
          .having(
            (state) => state.savedInstruments,
            'saved instruments',
            isEmpty,
          )
          .having(
            (state) => state.selectedScalePreset,
            'selected preset',
            const ScalePreset.single(25.5),
          ),
    ],
  );

  blocTest<CalculatorBloc, CalculatorState>(
    'switches to My Guitars empty state when repository has no records',
    build: () => CalculatorBloc(
      repository: repository,
      engine: engine,
      myInstrumentsRepository: FakeMyInstrumentsRepository(),
      savedInstrumentMapper: mapper,
    ),
    act: (bloc) {
      bloc.add(const CalculatorStarted());
      bloc.add(const CalculatorModeSelected(CalculatorMode.myGuitars));
    },
    expect: () => [
      isA<CalculatorReady>(),
      isA<CalculatorReady>()
          .having(
            (state) => state.selectedMode,
            'mode',
            CalculatorMode.myGuitars,
          )
          .having((state) => state.isMyGuitarsEmptyState, 'empty state', true),
    ],
  );

  blocTest<CalculatorBloc, CalculatorState>(
    'selects latest updated saved instrument when entering My Guitars',
    build: () => CalculatorBloc(
      repository: repository,
      engine: engine,
      myInstrumentsRepository: FakeMyInstrumentsRepository(
        initialRecords: [
          buildSavedInstrumentRecord(
            id: 'older',
            name: 'Older',
            kind: SavedInstrumentKind.guitar,
            stringSetId: SavedStringSetId.dxl,
            updatedAt: DateTime.parse('2026-04-19T09:00:00.000Z'),
          ),
          buildSavedInstrumentRecord(
            id: 'latest',
            name: 'Latest',
            kind: SavedInstrumentKind.bass,
            stringSetId: SavedStringSetId.k1,
            updatedAt: DateTime.parse('2026-04-19T12:00:00.000Z'),
          ),
        ],
      ),
      savedInstrumentMapper: mapper,
    ),
    act: (bloc) {
      bloc.add(const CalculatorStarted());
      bloc.add(const CalculatorModeSelected(CalculatorMode.myGuitars));
    },
    expect: () => [
      isA<CalculatorReady>().having(
        (state) => state.selectedSavedInstrumentId,
        'selected record',
        'latest',
      ),
      isA<CalculatorReady>()
          .having(
            (state) => state.selectedMode,
            'mode',
            CalculatorMode.myGuitars,
          )
          .having(
            (state) => state.selectedSavedInstrumentId,
            'selected record',
            'latest',
          )
          .having(
            (state) => state.myGuitarsDraft?.type,
            'draft type',
            InstrumentType.bass,
          ),
    ],
  );

  blocTest<CalculatorBloc, CalculatorState>(
    'redirects saved bass instrument to bass editing mode',
    build: () => CalculatorBloc(
      repository: repository,
      engine: engine,
      myInstrumentsRepository: FakeMyInstrumentsRepository(
        initialRecords: [
          buildSavedInstrumentRecord(
            id: 'saved-bass',
            name: 'Stage Bass',
            kind: SavedInstrumentKind.bass,
            stringSetId: SavedStringSetId.k1,
          ),
        ],
      ),
      savedInstrumentMapper: mapper,
    ),
    act: (bloc) {
      bloc.add(const CalculatorStarted());
      bloc.add(const CalculatorModeSelected(CalculatorMode.myGuitars));
      bloc.add(const CalculatorSavedInstrumentEditRequested());
    },
    expect: () => [
      isA<CalculatorReady>(),
      isA<CalculatorReady>()
          .having(
            (state) => state.selectedMode,
            'mode',
            CalculatorMode.myGuitars,
          )
          .having(
            (state) => state.myGuitarsDraft?.type,
            'saved draft type',
            InstrumentType.bass,
          ),
      isA<CalculatorReady>()
          .having((state) => state.selectedMode, 'mode', CalculatorMode.bass)
          .having(
            (state) => state.bassDraft.type,
            'bass draft type',
            InstrumentType.bass,
          )
          .having(
            (state) => state.bassDraft.strings.first.note.label,
            'first note',
            'G2',
          ),
    ],
  );

  blocTest<CalculatorBloc, CalculatorState>(
    'creates saved instrument from manual mode without leaving guitar mode',
    build: () => CalculatorBloc(
      repository: repository,
      engine: engine,
      myInstrumentsRepository: FakeMyInstrumentsRepository(
        now: () => DateTime.parse('2026-04-19T10:00:00.000Z'),
      ),
      savedInstrumentMapper: mapper,
    ),
    act: (bloc) {
      bloc.add(const CalculatorStarted());
      bloc.add(
        const CalculatorSaveSubmitted(
          SaveInstrumentSubmission(
            action: SaveInstrumentAction.create,
            name: 'Studio Guitar',
            kind: SavedInstrumentKind.guitar,
          ),
        ),
      );
    },
    expect: () => [
      isA<CalculatorReady>(),
      isA<CalculatorReady>()
          .having((state) => state.selectedMode, 'mode', CalculatorMode.guitar)
          .having(
            (state) => state.savedInstruments.first.name,
            'saved instrument name',
            'Studio Guitar',
          )
          .having(
            (state) => state.selectedSavedInstrumentId,
            'selected saved id',
            isNotNull,
          ),
    ],
  );
}
