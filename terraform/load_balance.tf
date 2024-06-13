resource "aws_lb" "k8s_masters_lb" {
    name        = "k8s-masters-lb"
    internal    = true
    load_balancer_type = "network"
    subnets = module.vpc.public_subnets
    tags = {
        Terraform = "true"
        Environment = "prod"
  }
}

resource "aws_lb_target_group" "k8s_masters_api" {
    name = "k8s-masters-api"
    port = 6443
    protocol = "TCP"
    vpc_id = module.vpc.vpc_id
    target_type = "ip"

    health_check {
      port      = 6443
      protocol  = "TCP"
      interval  = 30
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "k8s_masters_lb_listener" {
    load_balancer_arn = aws_lb.k8s_masters_lb.arn
    port = 6443
    protocol = "TCP"

    default_action {
        target_group_arn = aws_lb_target_group.k8s_masters_api.id
        type = "forward"
    }
}

resource "aws_lb_target_group_attachment" "k8s_masters_attachment" {
    count = length(aws_instance.masters.*.id)
    target_group_arn = aws_lb_target_group.k8s_masters_api.arn
    target_id = aws_instance.masters.*.private_ip[count.index]
}