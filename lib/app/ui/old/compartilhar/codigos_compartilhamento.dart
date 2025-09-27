import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minha_saude_frontend/app/ui/old/compartilhar/visualizar_codigo.dart';
import 'package:minha_saude_frontend/app/ui/widgets/app/brand_app_bar.dart';
import 'selecionar_documentos.dart';

class CodigosCompartilhamento extends StatefulWidget {
  const CodigosCompartilhamento({super.key});

  @override
  State<CodigosCompartilhamento> createState() =>
      _CodigosCompartilhamentoState();
}

class _CodigosCompartilhamentoState extends State<CodigosCompartilhamento>
    with AutomaticKeepAliveClientMixin {
  static const double _documentIconSize = 48.0;

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> codigos = [];
  final Set<String> codigosExpandidos = {};

  void mostrarSnackbar(String mensagem) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2B3133),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        content: Row(
          children: [
            Expanded(
              child: Text(
                mensagem,
                style: const TextStyle(
                  color: Color(0xFFECF2F4),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  letterSpacing: 0.25,
                ),
              ),
            ),
            IconButton(
              onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
              icon: const Icon(Icons.close, size: 24, color: Color(0xFFECF2F4)),
              tooltip: 'Fechar',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _irParaCriarCodigo() async {
    final novoCodigo = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SelecionarDocumentos()),
    );

    if (novoCodigo != null) {
      setState(() {
        codigos.insert(0, novoCodigo);
      });
      mostrarSnackbar("Código '${novoCodigo['codigo']}' criado com sucesso");
    }
  }

  void _excluirCodigoDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final codigo = codigos[index]['codigo'] ?? '';
        return Center(
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
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 264,
                    child: Text(
                      'Desativar Código',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF171C1E),
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 264,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Tem certeza que deseja desativar o código ',
                            style: TextStyle(
                              color: Color(0xFF3F484B),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              letterSpacing: 0.25,
                            ),
                          ),
                          TextSpan(
                            text: codigo,
                            style: const TextStyle(
                              color: Color(0xFF3F484B),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                              letterSpacing: 0.25,
                            ),
                          ),
                          const TextSpan(
                            text: '? Essa ação não pode ser desfeita.',
                            style: TextStyle(
                              color: Color(0xFF3F484B),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 48,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Color(0xFFBFC8CB),
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: Color(0xFF3F484B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                codigos.removeAt(index);
                              });
                              Navigator.pop(context);
                              mostrarSnackbar(
                                'Compartilhamento removido com sucesso!',
                              );
                            },
                            child: Container(
                              height: 48,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFBA1A1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Desativar',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
              'assets/icons/document.svg',
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

  void _abrirVisualizarCodigo(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VisualizarCodigo(codigo: item)),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final isExpanded = codigosExpandidos.contains(item['codigo']);
    final documentos = List<Map<String, String>>.from(item['documentos'] ?? []);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _abrirVisualizarCodigo(item);
          },
          child: Container(
            width: double.infinity,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['codigo'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: item['codigo']),
                              );
                              mostrarSnackbar(
                                'Código copiado para a área de transferência',
                              );
                            },
                            child: const Icon(
                              Icons.copy,
                              size: 16,
                              color: Color(0xFF3F484B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Válido até ${item['validade']}'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    final index = codigos.indexOf(item);
                    _excluirCodigoDialog(index);
                  },
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Column(children: documentos.map(_buildDocumentoCard).toList()),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: const BrandAppBar(title: Text('Compartilhamento')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: codigos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum código gerado ainda.',
                        style: TextStyle(
                          color: Color(0xFF3F484B),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: codigos.length,
                      itemBuilder: (context, index) =>
                          _buildCard(codigos[index]),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _irParaCriarCodigo,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFA9EDFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x4C000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Color(0xFF004E5C)),
                        SizedBox(width: 8),
                        Text(
                          'Novo Código',
                          style: TextStyle(
                            color: Color(0xFF004E5C),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
