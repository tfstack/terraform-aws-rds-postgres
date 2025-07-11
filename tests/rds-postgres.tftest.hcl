run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "test_rds_postgres" {
  variables {
    name                   = run.setup.name
    create_random_password = false
    master_password        = run.setup.postgres_password
    subnet_ids             = run.setup.database_subnet_ids
    vpc_security_group_ids = run.setup.security_group_ids
    skip_final_snapshot    = true
    deletion_protection    = false
    copy_tags_to_snapshot  = false
    force_destroy          = true
  }

  # Wait until the DB instance is available (up to ~15 min)
  # The test framework polls for state drift automatically after apply.

  # Assertions
  assert {
    condition     = resource.aws_db_instance.primary.engine == "postgres"
    error_message = "Primary instance should be postgres engine."
  }

  assert {
    condition     = length(resource.aws_db_instance.primary.id) > 0
    error_message = "Primary instance id should not be empty."
  }

  assert {
    condition     = length(output.arn) > 0
    error_message = "Module output 'arn' should not be empty."
  }

  assert {
    condition     = length(output.endpoint) > 0
    error_message = "Module output 'endpoint' should not be empty."
  }
}
