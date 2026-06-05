import 'package:cade_ufba/core/errors/failures.dart';
import 'package:cade_ufba/features/events/domain/entities/evento.dart';
import 'package:cade_ufba/features/events/domain/entities/filtro_evento.dart';
import 'package:cade_ufba/features/events/domain/repositories/event_repository.dart';
import 'package:cade_ufba/features/events/domain/usecases/listar_eventos.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements EventRepository {}

class _FakeFiltro extends Fake implements FiltroEvento {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeFiltro());
  });

  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  final eventoFake = Evento(
    id: '11111111-1111-1111-1111-111111111111',
    titulo: 'Palestra',
    inicio: DateTime.utc(2026, 7, 10, 14),
  );

  test('delega ao repository com filtro/limit/offset', () async {
    when(() => repo.listar(filtro: any(named: 'filtro'), limit: 20, offset: 0))
        .thenAnswer((_) async => Right<Failure, List<Evento>>([eventoFake]));

    final r = await ListarEventos(repo).call(
      const ParametrosListarEventos(filtro: FiltroEvento()),
    );

    expect(r, isA<Right<Failure, List<Evento>>>());
    r.fold(
      (_) => fail('esperava Right'),
      (lista) => expect(lista.single.id, eventoFake.id),
    );
  });

  test('propaga Failure do repository', () async {
    when(() => repo.listar(filtro: any(named: 'filtro'), limit: 20, offset: 0))
        .thenAnswer(
            (_) async => const Left<Failure, List<Evento>>(NetworkFailure()));

    final r = await ListarEventos(repo).call(
      const ParametrosListarEventos(filtro: FiltroEvento()),
    );

    expect(r, isA<Left<Failure, List<Evento>>>());
  });

  test('rejeita limit <= 0', () async {
    final r = await ListarEventos(repo).call(
      const ParametrosListarEventos(filtro: FiltroEvento(), limit: 0),
    );

    r.fold(
      (f) => expect((f as ValidationFailure).campo, 'limit'),
      (_) => fail('esperava Left'),
    );
    verifyZeroInteractions(repo);
  });

  test('rejeita limit > 100', () async {
    final r = await ListarEventos(repo).call(
      const ParametrosListarEventos(filtro: FiltroEvento(), limit: 500),
    );

    r.fold(
      (f) => expect((f as ValidationFailure).campo, 'limit'),
      (_) => fail('esperava Left'),
    );
    verifyZeroInteractions(repo);
  });

  test('rejeita offset negativo', () async {
    final r = await ListarEventos(repo).call(
      const ParametrosListarEventos(filtro: FiltroEvento(), offset: -1),
    );

    r.fold(
      (f) => expect((f as ValidationFailure).campo, 'offset'),
      (_) => fail('esperava Left'),
    );
    verifyZeroInteractions(repo);
  });
}
