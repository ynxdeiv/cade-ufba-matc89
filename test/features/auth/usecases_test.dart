import 'package:cade_ufba/core/errors/failures.dart';
import 'package:cade_ufba/core/usecases/usecase.dart';
import 'package:cade_ufba/features/auth/domain/entities/usuario.dart';
import 'package:cade_ufba/features/auth/domain/repositories/auth_repository.dart';
import 'package:cade_ufba/features/auth/domain/usecases/cadastrar.dart';
import 'package:cade_ufba/features/auth/domain/usecases/login.dart';
import 'package:cade_ufba/features/auth/domain/usecases/logout.dart';
import 'package:cade_ufba/features/auth/domain/usecases/recuperar_senha.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  group('Login', () {
    final params = const ParametrosLogin(email: 'a@b.com', senha: 'Senha123');
    const usuario = Usuario(id: '1', email: 'a@b.com');

    test('delega ao repository quando email e senha são válidos', () async {
      when(() => repo.login('a@b.com', 'Senha123'))
          .thenAnswer((_) async => const Right(usuario));

      final r = await Login(repo).call(params);

      expect(r, const Right<Failure, Usuario>(usuario));
      verify(() => repo.login('a@b.com', 'Senha123')).called(1);
    });

    test('retorna ValidationFailure quando email é inválido', () async {
      final r = await Login(repo)
          .call(const ParametrosLogin(email: 'invalido', senha: 'Senha123'));

      expect(r.isLeft(), true);
      r.fold(
        (f) {
          expect(f, isA<ValidationFailure>());
          expect((f as ValidationFailure).campo, 'email');
        },
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('retorna ValidationFailure quando senha é vazia', () async {
      final r = await Login(repo)
          .call(const ParametrosLogin(email: 'a@b.com', senha: ''));

      expect(r.isLeft(), true);
      r.fold(
        (f) {
          expect(f, isA<ValidationFailure>());
          expect((f as ValidationFailure).campo, 'senha');
        },
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('propaga AuthFailure do repository', () async {
      when(() => repo.login(any(), any()))
          .thenAnswer((_) async => const Left(AuthFailure('credenciais')));

      final r = await Login(repo).call(params);

      expect(r, const Left<Failure, Usuario>(AuthFailure('credenciais')));
    });

    test('faz trim no email antes de enviar ao repository', () async {
      when(() => repo.login('a@b.com', 'Senha123'))
          .thenAnswer((_) async => const Right(usuario));

      await Login(repo)
          .call(const ParametrosLogin(email: '  a@b.com  ', senha: 'Senha123'));

      verify(() => repo.login('a@b.com', 'Senha123')).called(1);
    });
  });

  group('Cadastrar', () {
    final params = const ParametrosCadastro(
      nome: 'Maria',
      email: 'm@x.com',
      senha: 'Senha123',
    );
    const usuario = Usuario(id: '1', email: 'm@x.com', nome: 'Maria');

    test('delega ao repository quando todos os campos são válidos', () async {
      when(() => repo.cadastrar(
            email: 'm@x.com',
            senha: 'Senha123',
            nome: 'Maria',
          )).thenAnswer((_) async => const Right(usuario));

      final r = await Cadastrar(repo).call(params);

      expect(r, const Right<Failure, Usuario>(usuario));
    });

    test('rejeita nome vazio', () async {
      final r = await Cadastrar(repo).call(const ParametrosCadastro(
        nome: '',
        email: 'm@x.com',
        senha: 'Senha123',
      ));

      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'nome'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('rejeita email inválido', () async {
      final r = await Cadastrar(repo).call(const ParametrosCadastro(
        nome: 'Maria',
        email: 'sem-arroba',
        senha: 'Senha123',
      ));

      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'email'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('rejeita senha fraca (sem dígito)', () async {
      final r = await Cadastrar(repo).call(const ParametrosCadastro(
        nome: 'Maria',
        email: 'm@x.com',
        senha: 'somentetexto',
      ));

      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'senha'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('rejeita senha curta', () async {
      final r = await Cadastrar(repo).call(const ParametrosCadastro(
        nome: 'Maria',
        email: 'm@x.com',
        senha: 'A1b2',
      ));

      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'senha'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });
  });

  group('RecuperarSenha', () {
    test('delega ao repository quando email é válido', () async {
      when(() => repo.recuperarSenha('a@b.com'))
          .thenAnswer((_) async => const Right(null));

      final r = await RecuperarSenha(repo).call('a@b.com');

      expect(r.isRight(), true);
      verify(() => repo.recuperarSenha('a@b.com')).called(1);
    });

    test('rejeita email vazio', () async {
      final r = await RecuperarSenha(repo).call('');
      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'email'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });

    test('rejeita email inválido', () async {
      final r = await RecuperarSenha(repo).call('foo');
      r.fold(
        (f) => expect((f as ValidationFailure).campo, 'email'),
        (_) => fail('esperava Left'),
      );
      verifyZeroInteractions(repo);
    });
  });

  group('Logout', () {
    test('delega ao repository', () async {
      when(() => repo.logout()).thenAnswer((_) async => const Right(null));

      final r = await Logout(repo).call(const NoParams());

      expect(r.isRight(), true);
      verify(() => repo.logout()).called(1);
    });

    test('propaga Failure do repository', () async {
      when(() => repo.logout())
          .thenAnswer((_) async => const Left(NetworkFailure('offline')));

      final r = await Logout(repo).call(const NoParams());

      expect(r, const Left<Failure, void>(NetworkFailure('offline')));
    });
  });
}
