resource "aws_iam_role" "access_peg_engineering" {
    name = "access-peg-engineering"
    description = "Allows engineers to read all engineering resources and create and manage Pegasus engineering resources."

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = "*"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        "access-project" = "peg"
        "access-team" = "eng" 
    }
}

resource "aws_iam_role" "access_peg_quality_assurance" {
    name = "access-peg-quality-assurance"
    description = "Allows the QA team to read all QA resources and create and manage all Pegasus QA resources."
    
}

resource "aws_iam_role" "access_uni_engineering" {
    name = "access-uni-engineering"
    description = "Allows engineers to read all engineering resources and create and manage Unicorn engineering resources."
}

resource "aws_iam_role" "access_uni_quality_assurance" {
    name = "access-peg-quality-assurance"
    description = "Allows the QA team to read all QA resources and create and manage all Unicorn QA resources."
}