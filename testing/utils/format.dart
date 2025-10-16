import 'package:multiple_result/multiple_result.dart';

String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";
}

String formatCpf(String cpf) {
  // Remove any non-digit characters
  cpf = cpf.replaceAll(RegExp(r'\D'), '');

  if (cpf.length != 11) {
    return cpf;
  }

  return "${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}";
}

Result<DateTime, Exception> parseDateString(String dateString) {
  final parts = dateString.split('/');
  if (parts.length != 3) {
    return Error(FormatException("Invalid date format"));
  }

  final day = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[2]);

  return Success(DateTime(year, month, day));
}

String formatPhone(String telefone) {
  if (telefone.isEmpty) return telefone;

  // Remove non-digit characters
  final digits = telefone.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return telefone; // Not enough digits to format

  // Apply format (##) #####-####
  if (digits.length == 10) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6, 10)}';
  } else if (digits.length == 11) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
  } else {
    return telefone;
  }
}
