## Deploy do backend com Terraform

Arquivos desta pasta criam, via Elastic Beanstalk, toda a infraestrutura necessária para publicar a API na AWS utilizando **estado local** (`infra/terraform.tfstate`). Ótimo para fins de aula: basta ter as credenciais configuradas na máquina que executa o `terraform`.

### Recursos provisionados
- Bucket S3 exclusivo para armazenar o pacote da aplicação.
- Aplicação/ambiente Elastic Beanstalk na plataforma *Corretto 17 / Amazon Linux 2023*.
- Banco PostgreSQL (RDS) público para fins didáticos, com *security group* liberando a porta `5432`.
- Upload automático do `application.jar` para o S3 e criação da `application version`.

### Pré-requisitos
1. Terraform 1.5+ instalado.
2. Credenciais AWS exportadas como `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` (ou perfil configurado via AWS CLI).
3. Backend compilado localmente: `./mvnw clean package` (gera `target/api-0.0.1-SNAPSHOT.jar`).

### Executando localmente
1. Entre na pasta `infra/`.
2. Inicialize os providers (irá baixar AWS/Archive/Random):  
   ```bash
   terraform init
   ```
3. Execute o `plan`, informando usuário e senha do banco:  
   ```bash
   terraform plan \
     -var db_user=admin \
     -var db_password=senhaSuperSecreta
   ```
4. Aplique as mudanças quando estiver tudo certo:  
   ```bash
   terraform apply \
     -var db_user=admin \
     -var db_password=senhaSuperSecreta
   ```

> **Dica:** Se o JAR tiver outro nome/caminho, sobrescreva `artifact_jar_path`. Também é possível fixar um nome de bucket (`artifact_bucket_name`) ou um `version_label` específico.

### Executando via GitHub Actions
O workflow `.github/workflows/terraform.yml` compila o backend, injeta o caminho do JAR como variável (`TF_VAR_artifact_jar_path`), aplica o Terraform e publica o `terraform.tfstate` como artifact privado do repositório. Para usar:

1. Configure os segredos `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `TF_DB_USER` e `TF_DB_PASSWORD`.
2. Opcionalmente defina `ARTIFACT_BUCKET_NAME` e `AWS_REGION` em *Repository Variables*.
3. Dispare o workflow manualmente em **Actions → Provision Infrastructure → Run workflow**.

> **Importante:** Como o backend é local, o estado fica salvo no artifact do GitHub Actions. Sem baixar o estado anterior, um novo run não terá histórico dos recursos. Para manter tudo alinhado, execute sempre o mesmo workflow para `apply/destroy` e evite apagar os artifacts até terminar a aula.

### Limpeza
Depois da aula, destrua tudo para não consumir créditos:
```bash
terraform destroy -var db_user=admin -var db_password=senhaSuperSecreta
```
