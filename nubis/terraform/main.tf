module "worker" {
  source            = "github.com/nubisproject/nubis-terraform//worker?ref=v2.0.4"
  region            = "${var.region}"
  environment       = "${var.environment}"
  account           = "${var.account}"
  service_name      = "${var.service_name}"
  purpose           = "webserver"
  ami               = "${var.ami}"
  elb               = "${module.load_balancer.name}"
  nubis_sudo_groups = "nubis_global_admins,team_webops"
  instance_type     = "t2.small"
  min_instances     = 1
}

module "load_balancer" {
  source               = "github.com/nubisproject/nubis-terraform//load_balancer?ref=v2.0.4"
  region               = "${var.region}"
  environment          = "${var.environment}"
  account              = "${var.account}"
  service_name         = "${var.service_name}"
  health_check_target  = "HTTP:443/_health_"
  ssl_cert_name_prefix = "phonebook"
}

module "dns" {
  source       = "github.com/nubisproject/nubis-terraform//dns?ref=v2.0.4"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  target       = "${module.load_balancer.address}"
}

module "cache" {
  source                 = "github.com/nubisproject/nubis-terraform//cache?ref=v2.0.4"
  region                 = "${var.region}"
  environment            = "${var.environment}"
  account                = "${var.account}"
  service_name           = "${var.service_name}"
  client_security_groups = "${module.worker.security_group}"
}
