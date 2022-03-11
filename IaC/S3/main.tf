provider "aws" {
  region = "eu-west-1"
}

data "aws_canonical_user_id" "eng103a_project_owner" {}

resource "aws_s3_bucket" "eng103a-project-s3-bucket" {
  bucket = "eng103a-project-s3-bucket"

  tags = {
    Name = "eng103a-project-s3-bucket"
  }
}

resource "aws_s3_bucket_acl" "eng103a_s3_acl" {
  bucket = aws_s3_bucket.eng103a-project-s3-bucket.id

  access_control_policy {
    # grant read access to anybody
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
      }
      permission = "READ"
    }
    # grant write access only to authenticated users
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
      }
      permission = "WRITE"
    }

    owner {
      id = data.aws_canonical_user_id.eng103a_project_owner.id
    }

  }

}
