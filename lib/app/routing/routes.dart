// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const tos = '/register/tos';
  static const register = '$tos/$registerRelative';
  static const registerRelative = 'form';

  // Documentos routes
  static const documentos = '/$documentosRelative';
  static const documentosRelative = 'documentos';
  static const documentosUpload = '$documentos/$documentosUploadRelative';
  static const documentosUploadRelative = 'upload';
  static const documentosScan = '$documentos/$documentosScanRelative';
  static const documentosScanRelative = 'scan';
  static String documentosWithId(String id) => '$documentos/$id';

  // Compartilhar routes
  static const compartilhar = '/compartilhar';

  // Lixeira routes
  static const lixeira = '/lixeira';
  static String lixeiraWithId(String id) => '$lixeira/$id';

  // Configuracoes routes
  static const configuracoes = '/configuracoes';
  static const editNome = '$configuracoes/$editNomeRelative';
  static const editNomeRelative = 'edit/nome';
  static const editTelefone = '$configuracoes/$editTelefoneRelative';
  static const editTelefoneRelative = 'edit/telefone';
  static const editBirthdate = '$configuracoes/$editBirthdateRelative';
  static const editBirthdateRelative = 'edit/birthdate';
}
