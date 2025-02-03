# Lambda Function to Start/Stop EC2
resource "aws_lambda_function" "ec2_scheduler" {
  filename      = "lambda_function.zip"
  function_name = "ec2-start-stop"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      AWS_REGION  = "eu-west-2"
      INSTANCE_ID = aws_instance.postgres_ec2.id
    }
  }
}

# IAM Role for Lambda to Control EC2
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_ec2_control" {
  name        = "lambda-ec2-control"
  description = "Allow Lambda to start/stop EC2"
  policy      = jsonencode({
    Statement = [{
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_ec2_control.arn
}

# EventBridge Scheduler to Trigger Lambda
resource "aws_cloudwatch_event_rule" "ec2_start_schedule" {
  name                = "ec2-start-schedule"
  schedule_expression = "cron(0 7 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "ec2_stop_schedule" {
  name                = "ec2-stop-schedule"
  schedule_expression = "cron(30 20 * * ? *)"
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule = aws_cloudwatch_event_rule.ec2_start_schedule.name
  arn  = aws_lambda_function.ec2_scheduler.arn
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule = aws_cloudwatch_event_rule.ec2_stop_schedule.name
  arn  = aws_lambda_function.ec2_scheduler.arn
}
