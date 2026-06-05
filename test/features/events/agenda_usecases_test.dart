import 'package:cade_ufba/core/errors/failures.dart';
import 'package:cade_ufba/features/events/domain/entities/evento.dart';
import 'package:cade_ufba/features/events/domain/entities/filtro_evento.dart';
import 'package:cade_ufba/features/events/domain/repositories/event_repository.dart';
import 'package:cade_ufba/features/events/domain/usecases/adicionar_agenda.dart';
import 'package:cade_ufba/features/events/domain/usecases/obter_evento.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements EventRepository {}

class _FakeFiltro extends Fake implements FiltroEvento {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeFiltro()));

  late _MockRepo repo;
  setUp(() => repo = _MockRepo());

  final eventoFake = Evento(
    id: '11111111-1111-1111-1111-111111111111',
    titulo: 'Palestra',
    inicio: DateTime.utc(2026, 7, 10, 14),
  );

  group('ObterEvento', () {
    test('delega ao repo quando id é válido', () async {
      when(() => repo.obter(eventoFake.id))
          .thenAnswer((_) async => Right<Failure, Evento>(eventoFake));

      final r = await ObterEvento(repo)(eventoFake.id);

      expect(r, Right<Failure, Evento>(eventoFake));
      verify(() => repo.obter(eventoFake.id)).called(1);
    });

    test('faz trim do id', () async {
      when(() => repo.obter(eventoFake.id))
          .thenAnswer((_) async => Right<Failure, Evento>(eventoFake));

      await ObterEvento(repo)('  ${eventoFake.id}  ');

      verify(() => repo.obter(eventoFake.id)).called(1);
    });

    test('rejeita id vazio', () async {
      final r = await ObterEvento(repo)('');
      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'id'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('propaga Failure do repo', () async {
      when(() => repo.obter(any()))
          .thenAnswer((_) async => const Left(ServerFailure('boom')));

      final r = await ObterEvento(repo)(eventoFake.id);

      expect(r, const Left<Failure, Evento>(ServerFailure('boom')));
    });
  });

  group('AdicionarAgenda', () {
    test('delega ao repo', () async {
      when(() => repo.adicionarAgenda(eventoFake.id))
          .thenAnswer((_) async => const Right(null));

      final r = await AdicionarAgenda(repo)(eventoFake.id);

      expect(r.isRight(), true);
      verify(() => repo.adicionarAgenda(eventoFake.id)).called(1);
    });

    test('rejeita id vazio', () async {
      final r = await AdicionarAgenda(repo)('   ');
      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'eventId'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });
  });

  group('RemoverAgenda', () {
    test('delega ao repo', () async {
      when(() => repo.removerAgenda(eventoFake.id))
          .thenAnswer((_) async => const Right(null));

      final r = await RemoverAgenda(repo)(eventoFake.id);

      expect(r.isRight(), true);
      verify(() => repo.removerAgenda(eventoFake.id)).called(1);
    });

    test('rejeita id vazio', () async {
      final r = await RemoverAgenda(repo)('');
      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'eventId'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });
  });
}
