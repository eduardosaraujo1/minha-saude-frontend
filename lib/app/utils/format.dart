String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}

String formatCpf(String cpf) {
  // Remove any non-digit characters
  cpf = cpf.replaceAll(RegExp(r'\D'), '');

  if (cpf.length != 11) {
    throw FormatException("Invalid CPF");
  }

  return "${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}";
}
