locals {
  workspace_suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  name_prefix      = "${var.app_name}${local.workspace_suffix}"
  artifact_source  = abspath(var.artifact_jar_path)
  artifact_hash    = filesha256(local.artifact_source)
  version_label    = var.version_label != "" ? var.version_label : substr(local.artifact_hash, 0, 16)
  bundle_zip_path  = "${path.module}/bundle-${local.version_label}.zip"
}

resource "random_id" "bucket_suffix" {
  byte_length = 2
}

locals {
  artifact_bucket_name = var.artifact_bucket_name != "" ? var.artifact_bucket_name : "${var.app_name}-artifacts-${random_id.bucket_suffix.hex}"
}

data "archive_file" "bundle" {
  type        = "zip"
  output_path = local.bundle_zip_path

  # Empacota o JAR gerado pelo Maven como arquivo principal do bundle
  source_file = local.artifact_source

  # Adiciona um Procfile simples ao zip para orientar o Elastic Beanstalk
  source_content_filename = "Procfile"
  source_content          = "web: java -jar application.jar"
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = local.artifact_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "backend_bundle" {
  bucket       = aws_s3_bucket.artifacts.bucket
  key          = "beanstalk/${local.version_label}.zip"
  source       = data.archive_file.bundle.output_path
  etag         = data.archive_file.bundle.output_sha
  content_type = "application/zip"
}

resource "aws_elastic_beanstalk_application" "backend" {
  name        = "${local.name_prefix}-backend"
  description = "Aplicação Elastic Beanstalk para o backend Spring Boot."
}

resource "aws_elastic_beanstalk_application_version" "backend" {
  name        = local.version_label
  application = aws_elastic_beanstalk_application.backend.name
  bucket      = aws_s3_bucket.artifacts.bucket
  key         = aws_s3_object.backend_bundle.key
  description = "Versão gerada a partir do build ${local.version_label}"
}

resource "aws_elastic_beanstalk_environment" "backend_env" {
  name          = "${local.name_prefix}-backend-env"
  application   = aws_elastic_beanstalk_application.backend.name
  platform_arn  = "arn:aws:elasticbeanstalk:${var.region}::platform/Corretto 17 running on 64bit Amazon Linux 2023"
  tier          = "WebServer"
  version_label = aws_elastic_beanstalk_application_version.backend.name

  // Mantém as instâncias dentro do free tier
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  // Usa profile padrão criado automaticamente pela AWS (ajuste se a conta não tiver)
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  // Variáveis de ambiente que serão alimentadas pelos recursos do RDS
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_URL"
    value     = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/${aws_db_instance.postgres.db_name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_USERNAME"
    value     = var.db_user
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_DATASOURCE_PASSWORD"
    value     = var.db_password
  }

  // Mantemos as configurações padrão do load balancer (nenhum ajuste customizado necessário).
}
