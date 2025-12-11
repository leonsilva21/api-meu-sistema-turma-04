output "elastic_beanstalk_application" {
  description = "Nome da aplicação Elastic Beanstalk."
  value       = aws_elastic_beanstalk_application.backend.name
}

output "elastic_beanstalk_endpoint" {
  description = "Endpoint público do backend (gera após criação do ambiente)."
  value       = aws_elastic_beanstalk_environment.backend_env.endpoint_url
}

output "rds_endpoint" {
  description = "Host do banco PostgreSQL."
  value       = aws_db_instance.postgres.address
}

output "rds_db_name" {
  description = "Database padrão criado no RDS."
  value       = aws_db_instance.postgres.db_name
}

output "beanstalk_artifact_bucket" {
  description = "Bucket S3 (pré-criado) para upload das versões do backend."
  value       = aws_s3_bucket.artifacts.bucket
}

output "beanstalk_version_label" {
  description = "Version label atualmente publicado no Elastic Beanstalk."
  value       = aws_elastic_beanstalk_application_version.backend.name
}
