import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/asset.dart';

class VisualizarCodigo extends StatelessWidget {
  static const double _documentIconSize = 48.0;

  final Map<String, dynamic> codigo;

  const VisualizarCodigo({super.key, required this.codigo});

  Widget _buildDocumentoCard(Map<String, String> doc) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5FAFC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFBFC8CB)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['titulo'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Paciente: ${doc['paciente'] ?? ''}'),
                Text('Tipo: ${doc['tipo'] ?? ''}'),
                Text('Doutor(a): ${doc['doutor'] ?? ''}'),
                Text('Data: ${doc['data'] ?? ''}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> documentos = List<Map<String, String>>.from(
      codigo['documentos'] ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(codigo['codigo']),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView(
                children: documentos.map(_buildDocumentoCard).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
