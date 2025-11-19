# Network Access Control Lists (NACLs) for Defense-in-Depth Security
# Provides stateless network filtering as an additional security layer

# NACL for public subnets (DMZ)
resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-public-nacl"
    Tier = "public"
    Environment = var.environment
  })
}

# NACL for private application subnets
resource "aws_network_acl" "private_app" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_app_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-private-app-nacl"
    Tier = "application"
    Environment = var.environment
  })
}

# NACL for private database subnets
resource "aws_network_acl" "private_db" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-private-db-nacl"
    Tier = "database"
    Environment = var.environment
  })
}

# NACL for isolated management subnets
resource "aws_network_acl" "isolated_mgmt" {
  vpc_id     = var.vpc_id
  subnet_ids = var.isolated_mgmt_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.environment}-chainocracy-isolated-mgmt-nacl"
    Tier = "management"
    Environment = var.environment
  })
}

# Public subnet NACL rules
# Inbound rules for public subnets
resource "aws_network_acl_rule" "public_inbound_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_inbound_ssh_admin" {
  count = length(var.allowed_ssh_cidrs)

  network_acl_id = aws_network_acl.public.id
  rule_number    = 120 + count.index
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.allowed_ssh_cidrs[count.index]
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_inbound_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Outbound rules for public subnets
resource "aws_network_acl_rule" "public_outbound_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_outbound_http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_outbound_app_tier" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.app_port
  to_port        = var.app_port
}

resource "aws_network_acl_rule" "public_outbound_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_outbound_dns" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "public_outbound_ntp" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 220
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 123
  to_port        = 123
}

# Private application subnet NACL rules
# Inbound rules for private application subnets
resource "aws_network_acl_rule" "private_app_inbound_alb" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.app_port
  to_port        = var.app_port
}

resource "aws_network_acl_rule" "private_app_inbound_health_check" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.health_check_port
  to_port        = var.health_check_port
}

resource "aws_network_acl_rule" "private_app_inbound_service_mesh" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.service_mesh_port
  to_port        = var.service_mesh_port
}

resource "aws_network_acl_rule" "private_app_inbound_ssh" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_app_inbound_ephemeral" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Outbound rules for private application subnets
resource "aws_network_acl_rule" "private_app_outbound_db" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "private_app_outbound_cache" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 6379
  to_port        = 6379
}

resource "aws_network_acl_rule" "private_app_outbound_https" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_app_outbound_service_mesh" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.service_mesh_port
  to_port        = var.service_mesh_port
}

resource "aws_network_acl_rule" "private_app_outbound_dns" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 200
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "private_app_outbound_ntp" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 210
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 123
  to_port        = 123
}

resource "aws_network_acl_rule" "private_app_outbound_ephemeral" {
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 220
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Private database subnet NACL rules
# Inbound rules for private database subnets
resource "aws_network_acl_rule" "private_db_inbound_postgres" {
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "private_db_inbound_replication" {
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "private_db_inbound_ssh" {
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 22
  to_port        = 22
}

# Outbound rules for private database subnets (minimal outbound access)
resource "aws_network_acl_rule" "private_db_outbound_replication" {
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "private_db_outbound_ephemeral" {
  network_acl_id = aws_network_acl.private_db.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

# Isolated management subnet NACL rules
# Inbound rules for isolated management subnets
resource "aws_network_acl_rule" "isolated_mgmt_inbound_ssh" {
  count = length(var.allowed_ssh_cidrs)

  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 100 + count.index
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.allowed_ssh_cidrs[count.index]
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "isolated_mgmt_inbound_monitoring" {
  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 9090
  to_port        = 9090
}

resource "aws_network_acl_rule" "isolated_mgmt_inbound_grafana" {
  count = length(var.monitoring_access_cidrs)

  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 130 + count.index
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.monitoring_access_cidrs[count.index]
  from_port      = 3000
  to_port        = 3000
}

resource "aws_network_acl_rule" "isolated_mgmt_inbound_ephemeral" {
  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Outbound rules for isolated management subnets
resource "aws_network_acl_rule" "isolated_mgmt_outbound_vpc" {
  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "isolated_mgmt_outbound_https" {
  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "isolated_mgmt_outbound_dns" {
  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 120
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "isolated_mgmt_outbound_ntp" {
  network_acl_id = aws_network_acl.isolated_mgmt.id
  rule_number    = 130
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 123
  to_port        = 123
}

# Deny rules for enhanced security (explicit deny for suspicious traffic)
resource "aws_network_acl_rule" "deny_suspicious_inbound" {
  for_each = {
    public      = aws_network_acl.public.id
    private_app = aws_network_acl.private_app.id
    private_db  = aws_network_acl.private_db.id
    isolated    = aws_network_acl.isolated_mgmt.id
  }

  network_acl_id = each.value
  rule_number    = 900
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 23  # Telnet
  to_port        = 23
}

resource "aws_network_acl_rule" "deny_ftp_inbound" {
  for_each = {
    public      = aws_network_acl.public.id
    private_app = aws_network_acl.private_app.id
    private_db  = aws_network_acl.private_db.id
    isolated    = aws_network_acl.isolated_mgmt.id
  }

  network_acl_id = each.value
  rule_number    = 910
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 21  # FTP
  to_port        = 21
}

resource "aws_network_acl_rule" "deny_smtp_inbound" {
  for_each = {
    public      = aws_network_acl.public.id
    private_app = aws_network_acl.private_app.id
    private_db  = aws_network_acl.private_db.id
    isolated    = aws_network_acl.isolated_mgmt.id
  }

  network_acl_id = each.value
  rule_number    = 920
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 25  # SMTP
  to_port        = 25
}
