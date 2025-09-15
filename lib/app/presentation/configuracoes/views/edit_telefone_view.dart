import 'package:flutter/material.dart';

class EditarTelefone extends StatefulWidget {
  final String telefoneAtual;

  const EditarTelefone({super.key, required this.telefoneAtual});

  @override
  State<EditarTelefone> createState() => _EditarTelefoneState();
}

class _EditarTelefoneState extends State<EditarTelefone> {
  final TextEditingController _telefoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _telefoneController.text = widget.telefoneAtual;
  }

  @override
  void dispose() {
    _telefoneController.dispose();
    super.dispose();
  }

  void _verificarTelefone() {
    if (_formKey.currentState!.validate()) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) =>
      //         EditarCodigo(telefone: _telefoneController.text),
      //   ),
      // ).then((verificado) {
      //   if (verificado != null && verificado == true) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Telefone verificado e atualizado com sucesso!'),
      //         duration: Duration(seconds: 2),
      //       ),
      //     );
      //     Navigator.pop(context, _telefoneController.text);
      //   }
      // });
    }
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe um telefone';
    }

    final numeros = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numeros.length != 11) {
      return 'Telefone deve ter 11 dígitos';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Campo de telefone
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(00) 00000-0000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: _validarTelefone,
                onChanged: (value) {
                  final digits = value.replaceAll(RegExp(r'[^\d]'), '');

                  if (digits.length <= 11) {
                    String formatted = '';
                    if (digits.isNotEmpty) {
                      formatted =
                          '(${digits.substring(0, digits.length > 2 ? 2 : digits.length)}';
                    }
                    if (digits.length > 2) {
                      formatted +=
                          ') ${digits.substring(2, digits.length > 7 ? 7 : digits.length)}';
                    }
                    if (digits.length > 7) {
                      formatted += '-${digits.substring(7)}';
                    }
                    _telefoneController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // Botões Verificar e Cancelar lado a lado
              Row(
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFCEE7EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Botão Cancelar
                        },
                        child: Container(
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
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verificarTelefone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006879),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Verificar Telefone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
