void main() {
  // ## Lixeira

  // | Método | Endpoint            | Descrição               |
  // | ------ | ------------------- | ----------------------- |
  // | GET    | /trash              | Listar documentos       |
  // | GET    | /trash/{id}         | Ver documento           |
  // | POST   | /trash/{id}/restore | Restaurar documento     |
  // | POST   | /trash/{id}/destroy | Excluir permanentemente |

  // ### GET /trash

  // **Payload:**

  // ```json
  // {
  //     "page": "integer (opcional)",
  //     "per_page": "integer (opcional)"
  // }
  // ```

  // **Response:**

  // ```json
  // {
  //     "data": [
  //         {
  //             "id_documento": "integer",
  //             "titulo": "string"
  //         }
  //     ],
  // }
  // ```

  // ### GET /trash/{id}

  // **Payload:**

  // ```json
  // {}
  // ```

  // **Response:**

  // ```json
  // {
  //     "id_documento": "integer",
  //     "titulo": "string",
  //     "nome_paciente": "string (opcional)",
  //     "nome_medico": "string (opcional)",
  //     "tipo_documento": "string (opcional)",
  //     "data_documento": "string (YYYY-MM-DD, opcional)",
  //     "created_at": "string (YYYY-MM-DD)",
  //     "deleted_at": "string (YYYY-MM-DD, opcional)",
  //     "caminho_arquivo": "string (opcional)"
  // }
  // ```

  // ### POST /trash/{id}/restore

  // **Payload:**

  // ```json
  // {}
  // ```

  // **Response:**

  // ```json
  // {
  //     "status": "success | error",
  //     "message": "string (opcional)"
  // }
  // ```

  // ### POST /trash/{id}/destroy

  // **Payload:**

  // ```json
  // {}
  // ```

  // **Response:**

  // ```json
  // {
  //     "status": "success | error",
  //     "message": "string (opcional)"
  // }
  // ```
}
