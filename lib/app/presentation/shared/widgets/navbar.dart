import 'package:flutter/material.dart';

enum NavbarIcon { nenhum, mais, sort }

class Navbar extends StatelessWidget {
  final bool mostrarImagem;
  final bool mostrarIconeVoltar;
  final String? titulo;
  final NavbarIcon tipoIconeDireito;
  final VoidCallback? onIconeDireitoPressed;
  final VoidCallback? onVoltarPressed; // Adicione este parâmetro

  const Navbar({
    super.key,
    this.mostrarImagem = false,
    this.mostrarIconeVoltar = false,
    this.titulo,
    this.tipoIconeDireito = NavbarIcon.nenhum,
    this.onIconeDireitoPressed,
    this.onVoltarPressed, // Adicione aqui
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    IconData? _icone;
    switch (tipoIconeDireito) {
      case NavbarIcon.mais:
        _icone = Icons.more_vert;
        break;
      case NavbarIcon.sort:
        _icone = Icons.sort;
        break;
      case NavbarIcon.nenhum:
        _icone = null;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.01,
      ),
      color: const Color(0xFFE9EFF1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (mostrarIconeVoltar)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      onVoltarPressed ??
                      () => Navigator.pop(context), // Use o callback
                ),
              mostrarImagem
                  ? Image.asset(
                      'assets/images/LogoMinhaSaude.png',
                      width: size.width * 0.25,
                      height: size.height * 0.05,
                      fit: BoxFit.contain,
                    )
                  : Text(
                      titulo ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF171C1E),
                      ),
                    ),
            ],
          ),
          if (_icone != null)
            IconButton(icon: Icon(_icone), onPressed: onIconeDireitoPressed),
        ],
      ),
    );
  }
}
