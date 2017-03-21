module "worker" {
  source            = "github.com/nubisproject/nubis-terraform//worker?ref=v1.3.0"
  region            = "${var.region}"
  environment       = "${var.environment}"
  account           = "${var.account}"
  service_name      = "${var.service_name}"
  purpose           = "webserver"
  ami               = "${var.ami}"
  elb               = "${module.load_balancer.name}"
  nubis_sudo_groups = "nubis_global_admins,team_webops"
  min_instances     = 1
  max_instances     = 1
}

module "load_balancer" {
  source       = "github.com/nubisproject/nubis-terraform//load_balancer?ref=v1.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  health_check_target = "HTTP:443/"
}

module "dns" {
  source       = "github.com/nubisproject/nubis-terraform//dns?ref=v1.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  target       = "${module.load_balancer.address}"
}

