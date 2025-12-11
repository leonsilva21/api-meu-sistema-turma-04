// Variáveis mínimas para parametrizar a infraestrutura
variable "region" {
  description = "Região AWS onde os recursos serão criados."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Nome base da aplicação (usado em Elastic Beanstalk, buckets, etc.)."
  type        = string
  default     = "meu-sistema"
}

variable "db_user" {
  description = "Usuário administrador do banco PostgreSQL."
  type        = string
}

variable "db_password" {
  description = "Senha do usuário administrador do banco PostgreSQL."
  type        = string
  sensitive   = true
}

variable "artifact_bucket_name" {
  description = "Nome fixo do bucket S3 de artefatos (deixe vazio para criar um nome único automaticamente)."
  type        = string
  default     = ""
}

variable "artifact_jar_path" {
  description = "Caminho para o JAR gerado pelo Maven que será empacotado e enviado ao Elastic Beanstalk."
  type        = string
  default     = "../target/api-0.0.1-SNAPSHOT.jar"
}

variable "version_label" {
  description = "Label opcional para a versão do Elastic Beanstalk (por padrão usa o hash do artefato)."
  type        = string
  default     = ""
}
