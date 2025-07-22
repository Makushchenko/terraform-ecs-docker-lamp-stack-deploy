/*-----------------------------ECS_ECR------------------------------*/

variable "public_subnets" {
  default = ["10.10.100.0/24", "10.10.101.0/24"]
}


variable "private_subnets" {
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}


variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}


# create ECR repository
resource "aws_ecr_repository" "nginx-image" {
  name                 = "nginx-image-storage"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name     = "nginx-image"
    "devops" = "ecs"
  }
}


# set permissions to user on docker.sock
resource "null_resource" "permissions_docker_sock" {
  provisioner "local-exec" {
    command = "sudo chmod 666 /var/run/docker.sock"
  }
}


# wait for permissions will be set
resource "time_sleep" "wait_per_docker_sock" {
  depends_on = [null_resource.permissions_docker_sock]

  create_duration = "2s"
}


# Pulls the image
resource "docker_image" "nginx" {
  name = "nginx:latest"
}


# run script to tag and push image to ecr
resource "null_resource" "docker" {
  # always run command on apply
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "chmod +x /home/oleksandr/Desktop/terraform/ecs_ecr/ecs.sh && /home/oleksandr/Desktop/terraform/ecs_ecr/ecs.sh"
  }
}


#create VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name     = "devops_vpc"
    "devops" = "ecs"
  }
}


#create public subnet
resource "aws_subnet" "devops_subnet_public" {
  vpc_id                  = aws_vpc.devops_vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name     = "devops-subnet-public"
    "devops" = "ecs"
  }
}


#create internet gateway
resource "aws_internet_gateway" "devops_int_gateway" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name     = "devops_gw"
    "devops" = "ecs"
  }
}


#create public route table (assosiated with internet gateway)
resource "aws_route_table" "devops_rt_public" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name     = "devops_rt_public"
    "devops" = "ecs"
  }
}


# create routes
resource "aws_route" "devops_r_public" {
  route_table_id         = aws_route_table.devops_rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devops_int_gateway.id
}


# make association route table and subnet
resource "aws_route_table_association" "devops_rta_public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.devops_subnet_public.*.id, count.index)
  route_table_id = aws_route_table.devops_rt_public.id
}


# create iam role for executing ecs tasks
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "devops-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name     = "devops-ecsTaskExecutionRole"
    "devops" = "ecs"
  }
}


# create iam policy
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


# attach policy to role
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# create AWS ECS cluster for nginx image
resource "aws_ecs_cluster" "devops_ecs_cluster" {
  name = "devops_nginx_cluster"
  tags = {
    Name     = "nginx-cluster"
    "devops" = "ecs"
  }
}


resource "aws_cloudwatch_log_group" "devops_log_group" {
  name = "devops_nginx_cluster_logs"
  tags = {
    Name     = "nginx-logs"
    "devops" = "ecs logs"
  }
}


resource "aws_ecs_task_definition" "devops_ecs_task" {
  family = "custom-nginx-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "nginx-container",
      "image": "346832455654.dkr.ecr.us-east-1.amazonaws.com/custom-nginx-web-server:latest",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.devops_log_group.id}",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "nginx-cluster"
        }
      },
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name     = "devops-ecs-td"
    "devops" = "ecs-task-def"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.devops_ecs_task.family
}


resource "aws_ecs_service" "devops-ecs-service" {
  name                 = "custom_nginx-ecs-service"
  cluster              = aws_ecs_cluster.devops_ecs_cluster.id
  task_definition      = "${aws_ecs_task_definition.devops_ecs_task.family}:${max(aws_ecs_task_definition.devops_ecs_task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.devops_subnet_public.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.custom-target_group.arn
    container_name   = "nginx-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}


resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.devops_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name     = "devops-service-sg"
    "devops" = "ecs"
  }
}


resource "aws_alb" "application_load_balancer" {
  name               = "devops-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.devops_subnet_public.*.id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name     = "devops-alb"
    "devops" = "ecs"
  }
}


resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.devops_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name     = "devops-alb-sg"
    "devops" = "ecs"
  }
}


resource "aws_lb_target_group" "custom-target_group" {
  name        = "custom-devops-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.devops_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/v1/status"
    unhealthy_threshold = "2"
  }

  tags = {
    Name     = "devops-alb-tg"
    "devops" = "ecs"
  }
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.custom-target_group.id
  }
}


output "load_balancer_ip" {
  value = aws_alb.application_load_balancer.dns_name
}


