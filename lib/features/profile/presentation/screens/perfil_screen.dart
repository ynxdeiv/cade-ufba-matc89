import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../domain/entities/perfil.dart';
import '../providers/profile_providers.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _curso = TextEditingController();
  final _foto = TextEditingController();
  VinculoUsuario? _vinculo;
  String? _ultimoIdPreenchido;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).carregar();
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _curso.dispose();
    _foto.dispose();
    super.dispose();
  }

  void _preencherFormulario(Perfil p) {
    if (_ultimoIdPreenchido == p.id) return;
    _ultimoIdPreenchido = p.id;
    _nome.text = p.nome ?? '';
    _curso.text = p.cursoDepartamento ?? '';
    _foto.text = p.fotoUrl ?? '';
    setState(() => _vinculo = p.vinculo);
  }

  Future<void> _salvar(Perfil atual) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final novo = atual.copyWith(
      nome: _nome.text.trim().isEmpty ? null : _nome.text.trim(),
      vinculo: _vinculo,
      cursoDepartamento:
          _curso.text.trim().isEmpty ? null : _curso.text.trim(),
      fotoUrl: _foto.text.trim().isEmpty ? null : _foto.text.trim(),
    );
    await ref.read(profileControllerProvider.notifier).salvar(novo);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final email = authState is Autenticado ? authState.usuario.email : '';
    final profileState = ref.watch(profileControllerProvider);

    ref.listen<ProfileState>(profileControllerProvider, (_, next) {
      if (next is ProfileCarregado) {
        _preencherFormulario(next.perfil);
        if (next.sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado')),
          );
        }
      }
      if (next is ProfileErro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure.mensagem ?? 'Falha ao atualizar perfil'),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppCores.neutro100,
      appBar: AppBar(
        backgroundColor: AppCores.azul900,
        foregroundColor: Colors.white,
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: _corpo(context, email, profileState),
      ),
    );
  }

  Widget _corpo(BuildContext context, String email, ProfileState state) {
    if (state is ProfileCarregando || state is ProfileIdle) {
      return const Center(child: CircularProgressIndicator());
    }

    final Perfil perfil = switch (state) {
      ProfileCarregado(:final perfil) => perfil,
      ProfileErro(:final perfilAnterior) =>
        perfilAnterior ?? const Perfil(id: ''),
      _ => const Perfil(id: ''),
    };

    final salvando = state is ProfileCarregado && state.salvando;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppCores.azul100,
                backgroundImage: (perfil.fotoUrl != null &&
                        perfil.fotoUrl!.isNotEmpty)
                    ? NetworkImage(perfil.fotoUrl!)
                    : null,
                child: (perfil.fotoUrl == null || perfil.fotoUrl!.isEmpty)
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/ufba_logo.png',
                          fit: BoxFit.contain,
                          semanticLabel: 'Brasão da UFBA',
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                email,
                style: const TextStyle(
                  color: AppCores.neutro700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VinculoUsuario>(
              value: _vinculo,
              decoration: const InputDecoration(
                labelText: 'Vínculo',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final v in VinculoUsuario.values)
                  DropdownMenuItem(value: v, child: Text(v.rotulo)),
              ],
              onChanged: (v) => setState(() => _vinculo = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _curso,
              decoration: const InputDecoration(
                labelText: 'Curso / Departamento',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foto,
              decoration: const InputDecoration(
                labelText: 'Foto (URL)',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return null;
                final uri = Uri.tryParse(t);
                if (uri == null || !uri.isAbsolute) return 'URL inválida';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: salvando ? null : () => _salvar(perfil),
              style: FilledButton.styleFrom(
                backgroundColor: AppCores.azul500,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).sair(),
              icon: const Icon(Icons.logout, color: AppCores.azul900),
              label: const Text(
                'Sair',
                style: TextStyle(color: AppCores.azul900),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppCores.azul900),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
