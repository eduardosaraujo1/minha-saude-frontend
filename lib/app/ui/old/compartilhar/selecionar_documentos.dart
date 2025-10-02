import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/asset.dart';

class SelecionarDocumentos extends StatefulWidget {
  const SelecionarDocumentos({super.key});

  @override
  State<SelecionarDocumentos> createState() => _SelecionarDocumentosState();
}

class _SelecionarDocumentosState extends State<SelecionarDocumentos> {
  static const int _codigoLength = 10;
  static const int _validadeDias = 7;
  static const double _documentIconSize = 48.0;
  static const double _radioIconSize = 24.0;

  final Map<String, bool> selecionados = {};
  final Map<String, List<String>> pacientes = {
    'Ana Beatriz Rocha': [
      'Exame de Sangue da Beatriz',
      'Receita pro Zoladex da Ana',
      'Tomografia do Abdômen',
      'Raio-x do Tórax',
    ],
    'Daniel Ferreira': [
      'Eletrocardiograma',
      'Receita para Omeprazol',
      'Resultado de Biópsia',
    ],
    'Jaqueline Souza': [
      'Consulta de Rotina',
      'Exame de Urina',
      'Ultrassom Renal',
    ],
    'Marcos Lima': [
      'Raio-x do Joelho',
      'Receita para Dipirona',
      'Tomografia Craniana',
    ],
  };

  final Map<String, Map<String, String>> metadadosDocumentos = {};

  @override
  void initState() {
    super.initState();
    for (var entry in pacientes.entries) {
      final nomePaciente = entry.key;
      for (var doc in entry.value) {
        selecionados[doc] = false;
        metadadosDocumentos[doc] = {
          'paciente': nomePaciente,
          'tipo': _tipoAleatorio(),
          'doutor': _doutorAleatorio(),
          'data': _dataAleatoria(),
        };
      }
    }
  }

  String gerarCodigoAleatorio() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(
      _codigoLength,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  bool get algumSelecionado =>
      selecionados.values.any((selecionado) => selecionado);

  String _tipoAleatorio() {
    const tipos = [
      'Raio-X',
      'Tomografia',
      'Ultrassom',
      'Receita',
      'Consulta',
      'Exame de Sangue',
      'Biópsia',
    ];
    return tipos[Random().nextInt(tipos.length)];
  }

  String _doutorAleatorio() {
    const doutores = [
      'Dr. Lucas Martins',
      'Dra. Paula Lima',
      'Dr. Fernando Souza',
      'Dra. Carolina Mendes',
    ];
    return doutores[Random().nextInt(doutores.length)];
  }

  String _dataAleatoria() {
    final now = DateTime.now();
    final randomDays = Random().nextInt(1500);
    final date = now.subtract(Duration(days: randomDays));
    return '${_mesPorExtenso(date.month)} de ${date.year}';
  }

  String _mesPorExtenso(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses[mes - 1];
  }

  Future<void> mostrarDialogConfirmacao() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
            child: Container(
              width: 312,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFFE4E9EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Criar código',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Você tem certeza que deseja compartilhar esses documentos?',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 24,
                      bottom: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            final codigo = gerarCodigoAleatorio();
                            final validade = DateTime.now().add(
                              Duration(days: _validadeDias),
                            );
                            final validadeFormatada =
                                '${validade.day.toString().padLeft(2, '0')}-${validade.month.toString().padLeft(2, '0')}-${validade.year} | ${validade.hour.toString().padLeft(2, '0')}:${validade.minute.toString().padLeft(2, '0')}';

                            final List<Map<String, String>> docsSelecionados =
                                [];

                            for (var entry in selecionados.entries) {
                              if (entry.value) {
                                final titulo = entry.key;
                                final metadata = metadadosDocumentos[titulo]!;
                                docsSelecionados.add({
                                  'titulo': titulo,
                                  'paciente': metadata['paciente']!,
                                  'tipo': metadata['tipo']!,
                                  'doutor': metadata['doutor']!,
                                  'data': metadata['data']!,
                                });
                              }
                            }

                            Navigator.of(context).pop({
                              'codigo': codigo,
                              'validade': validadeFormatada,
                              'documentos': docsSelecionados,
                            });
                          },
                          child: const Text('Compartilhar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Widget _buildDocumento(String titulo) {
    final selecionado = selecionados[titulo] ?? false;

    final conteudo = Container(
      width: 120,
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                width: _documentIconSize,
                height: _documentIconSize,
                child: SvgPicture.asset(
                  Asset.documentIcon,
                  width: _documentIconSize,
                  height: _documentIconSize,
                ),
              ),
              Positioned(
                left: 26,
                top: -2,
                child: Icon(
                  selecionado
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: Theme.of(context).colorScheme.primary,
                  size: _radioIconSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 112,
            child: Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          selecionados[titulo] = !selecionado;
        });
      },
      child: selecionado ? conteudo : Opacity(opacity: 0.5, child: conteudo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Documentos'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: pacientes.entries.map((entry) {
                  final nome = entry.key;
                  final docs = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: docs.map(_buildDocumento).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE9EFF1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color(0xFFCEE7EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: const Center(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Color(0xFF334A50),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: algumSelecionado
                        ? () async => await mostrarDialogConfirmacao()
                        : null,
                    child: Opacity(
                      opacity: algumSelecionado ? 1.0 : 0.4,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: const Color(0xFF006879),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: const Center(
                          child: Text(
                            'Próximo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
