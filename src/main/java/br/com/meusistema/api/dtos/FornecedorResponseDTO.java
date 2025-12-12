package br.com.meusistema.api.dtos;

import br.com.meusistema.api.enums.TipoFornecedorEnum;

public record FornecedorResponseDTO(
        Long id,
        String nomeFantasia,
        String email,
        String cnpj,
        TipoFornecedorEnum tipoFornecedor,
        EnderecoDTO endereco
) {
}
