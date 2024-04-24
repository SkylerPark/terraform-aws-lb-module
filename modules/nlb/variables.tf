variable "name" {
  description = "(필수) load balancer 이름."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "(선택) 리소스 태그 내용"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "(필수) load balancer 가 생성 될 VPC ID"
  type        = string
  nullable    = false
}

###################################################
# Network Load Balancer
###################################################
variable "is_public" {
  description = "(필수) load balancer 가 public 으로 할당할지 여부 Default: `true`"
  type        = bool
  default     = true
  nullable    = false
}

variable "ip_address_type" {
  description = "(선택) load balancer 의 서브넷에서 사용하는 IP 주소 유형. 가능한 값 `ipv4` or `dualstack` Default: `ipv4`"
  type        = string
  default     = "ipv4"
  nullable    = false
}

variable "network_mapping" {
  description = <<EOF
  (선택) load balancer 에 IP 주소 설정. 서브넷의 대상으로 트래픽을 라우팅 `network_mapping` 블록 내용.
    (필수) `subnet` - load balancer 에 연결할 서브넷 ID 각 영역당 하나의 서브넷만 할당 가능.
    (선택) `private_ipv4_address` - 내부 load balancer 를 위한 Private IP 주소.
    (선택) `ipv6_address` - IPv6 주소,
    (선택) `elastic_ip` - 인터넷 연결 load balancer 에 대한 elastic_ip 주소
  EOF
  type = list(object({
    subnet               = string
    private_ipv4_address = optional(string)
    ipv6_address         = optional(string)
    elastic_ip           = optional(string)
  }))
  default  = []
  nullable = false
}

variable "security_group_evaluation_on_privatelink_enabled" {
  description = "(선택) AWS PrivateLink 를 통해 NLB 로 전송되는 트래픽에 대한 인바운드 보안 그룹 규칙을 적용할지 여부. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

variable "access_log" {
  description = <<EOF
  (선택) access log 에 대한 설정. `access_log` 블록 내용.
    (선택) `enabled` - access log 를 활성화 할지에 대한 여부 Default: `false`.
    (선택) `bucket` - access log 를 적재할 버킷명.
    (선택) `prefix` - access log 를 적재할 버킷 prefix.
  EOF
  type = object({
    enabled = optional(bool, false)
    bucket  = optional(string)
    prefix  = optional(string)
  })
  default  = {}
  nullable = false
}

variable "route53_resolver_availability_zone_affinity" {
  description = <<EOF
  (선택) load balancer 가용영역간에 트래픽이 분산되는 방식을 결정하는 구성. Resolver를 사용하여 로드 밸런서 DNS 이름을 확인하는 클라이언트에 대한 내부 요청에만 적용. 허용 값 `ANY`, `PARTIAL`, `ALL`. Default: `ANY`.
    `ANY` - 클라이언트 DNS 쿼리는 load balancer 가용 영역에서 정산적인 IP 주소를 확인.
    `PARTIAL` - 클라이언트 DNS 쿼리의 85% 는 자체 가용영역에 있는 load balancer IP 주소를 선호.
    `ALL` - 클라이언트 DNS 쿼리는 자체 가용 영역의 load balancer IP 주소를 선호.
  EOF
  type        = string
  default     = "ANY"
  nullable    = false

  validation {
    condition     = contains(["ANY", "PARTIAL", "ALL"], var.route53_resolver_availability_zone_affinity)
    error_message = "Valid values are `ANY`, `PARTIAL`, `ALL`."
  }
}

variable "cross_zone_load_balancing_enabled" {
  description = "(선택) 영역 간 로드밸런싱 활성화 여부. Default: `true`"
  type        = bool
  default     = true
  nullable    = false
}

variable "deletion_protection_enabled" {
  description = "(선택) AWS API 를 통해 삭제 할지 여부 `true` 인 경우 비활성화. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

###################################################
# Listener(s)
###################################################
variable "listeners" {
  description = <<EOF
  (선택) load balancer 리스너 목록 입니다. `listener` 블록 내용.
    (필수) `port` - load balancer 리스너 포트 정보.
    (필수) `protocol` - load balancer 리스너 protocol 정보. 가능 한 값 `TCP`, `TLS`, 'UDP', 'TCP_UDP'.
    (필수) `target_group` - 리스너에 매핑시킬 target group 이름.
    (선택) `tls` - TLS Listener 에 필요한 설정. `protocol` 이 `TLS` 일때 사용. `tls` 블록 내용.
      (선택) `certificate` - SSL certificate arn.
      (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.
      (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때 사용. Default: `ELBSecurityPolicy-TLS13-1-2-2021-06`.
      (선택) `alpn_policy` - Application-Layer Protocol Negotiation (ALPN) 정책. ALPN 는 TLS hello message 교환 시 프로토콜 협상을 포함시키는 TLS 확장. `protocol` 이 `TLS` 일때 사용. 다음과 같은 설정이 가능 `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, `None`. Default: `None`.
  EOF
  type = list(object({
    port         = number
    protocol     = string
    target_group = string
    tls = optional(object({
      certificate             = optional(string)
      additional_certificates = optional(set(string), [])
      security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
      alpn_policy             = optional(string, "None")
    }), {})
  }))
  default  = []
  nullable = false
}

###################################################
# Target Group(s)
###################################################
variable "target_groups" {
  description = <<EOF
  (선택) target group 에 대한 Map 리스트 정보. `target_groups` 블록 내용.
    (필수) `target_type` - target group 에 대한 type. 다음 중 선택 가능 `ip`, `alb`, `instance`.
    (선택) `ip_address_type` - target group 에서 사용하는 IP 주소 유형. 다음중 선택 가능 `ipv4`, `ipv6`. `target_type` 이 `ip` 일때만 설정.
    (선택) `port` - 대상에 대한 수신 포트. `target_type` 이 `instance`, `ip` 일때만 설정.
    (선택) `protocol` - 대상에 대한 수신 프로토콜. 다음중 선택 가능 `TCP`, `HTTP`, `HTTPS` `target_type` 이 `instance`, `ip`, `alb` 일때만 설정.
    (선택) `proxy_protocol_v2` - 프록시 프로토콜v2 에 대한 지원 활성화 여부. Default: `false`.
    (선택) `preserve_client_ip` - 클라이언트 IP 보존 활성화 여부. 문서 참고 `https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html#client-ip-preservation`
    (선택) `connection_termination` - 등록시간이 초과되면 연결을 종료할지 여부. Default: `false`.
    (선택) `deregistration_delay` - 대상에 대한 드레에닝 설정. `0` 부터 `3600`(초) 설정 가능. Default: 300
    (선택) `stickiness_enabled` - sticky session 활성화 여부. Default: false
    (선택) `health_check` - 타겟 그룹에 타겟에 대한 health check 정보. `health_check` 블록 내용.
      (선택) `enabled` - health check 를 활성화에 대한 여부.
      (선택) `healthy_threshold` - 정상으로 간주하기 위한 연속 상태 확인 성공 횟수. `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.
      (선택) `interval` - 대상 확인에 대한 상태 확인 시간(초). `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.
      (선택) `matcher` - 대상에 대한 성공 코드. `200,202` or `200-299` 와 같이 설정 가능. GRPC 의 경우 `0` 부터 `99` 설정. `HTTP`, `HTTPS` 의 경우 `200` 부터 `499` 까지 설정.
      (선택) `path` - 상태 요청에 대한 path. Default: `/`
      (선택) `port` - 상태 확인에 대한 port 정보. `traffic-port`, `1` 에서 `65546` 까지 설정 가능.
      (선택) `protocol` - 상태 검사에 대한 protocol.
      (선택) `timeout` - 대상으로 부터 응답이 없으면 상태 확인 실패 의미하는 시간(초). `2` 부터 `120` 까지 설정 가능.
    (선택) 대상 그룹에 추가할 대상 집합. `targets` 블록 내용.
      (필수) `target_id` - 대상에 대한 ID 값.
      (선택) `port` - 대상에 대한 port.
      (선택) `availability_zone` - 대상에 대한 zone 영역.
  EOF
  type = map(object({
    target_type            = optional(string)
    ip_address_type        = optional(string, null)
    port                   = optional(number, null)
    protocol               = optional(string, null)
    proxy_protocol_v2      = optional(bool, false)
    preserve_client_ip     = optional(bool, null)
    connection_termination = optional(bool, false)
    deregistration_delay   = optional(number, 300)
    stickiness_enabled     = optional(bool, false)
    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 3)
      interval            = optional(number, 10)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, null)
      path                = optional(string, "/")
      port                = optional(number, null)
      protocol            = optional(string, null)
      timeout             = optional(number, 30)
    }), {})
    targets = optional(map(object({
      target_id         = optional(string)
      port              = optional(number, null)
      availability_zone = optional(string, null)
    })), {})
  }))
  default  = {}
  nullable = false
}

###################################################
# Security Group
###################################################
variable "default_security_group" {
  description = <<EOF
  (선택) load balancer 에 추가 security group 설정. `security_group` 블록 내용.
    (필수) `enabled` - security group 을 생성 할지 여부 Default: false
    (선택) `name` - security group 이름 설정하지 않으면, load balancer 의 이름으로 설정
    (선택) 수신에 대한 설정 `ingress_rules` 블록 내용.
      (필수) `id` - 수신 규칙의 ID 입니다 이값은 Terraform 코드 내에서만 사용.
      (선택) `description` - 규칙에 대한 설명.
      (필수) `protocol` - 규칙에 대한 protocol. `protocol` 이 `-1` 로 됫을댄 모든 프로토콜 모든 포트범위로 되며, `from_port` `to_port` 값은 정의 불가.
      (필수) `from_port` - 포트 범위의 시작 TCP, UDP protocols, or ICMP/ICMPv6 type.
      (필수) `to_port` - 포트 범위의 끝 TCP and UDP protocols, or an ICMP/ICMPv6 type.
      (선택) `ipv4_cidrs` - IPv4 에 대한 CIDR 리스트.
      (선택) `ipv6_cidrs` - IPv6에 대한 CIDR 리스트.
      (선택) `prefix_lists` - prefix list.
      (선택) `security_groups` - Security Group ID 리스트.
      (선택) `self` - self 보안그룹을 추가할 것인지 여부.
    (선택) `egress_rules` - security group 송신 정책 map
      (필수) `id` - 송신 규칙의 ID 입니다 이값은 Terraform 코드 내에서만 사용.
      (선택) `description` - 규칙에 대한 설명.
      (필수) `protocol` - 규칙에 대한 protocol. `protocol` 이 `-1` 로 됫을댄 모든 프로토콜 모든 포트범위로 되며, `from_port` `to_port` 값은 정의 불가.
      (필수) `from_port` - 포트 범위의 시작 TCP, UDP protocols, or ICMP/ICMPv6 type.
      (필수) `to_port` - 포트 범위의 끝 TCP and UDP protocols, or an ICMP/ICMPv6 type.
      (선택) `ipv4_cidrs` - IPv4 에 대한 CIDR 리스트.
      (선택) `ipv6_cidrs` - IPv6에 대한 CIDR 리스트.
      (선택) `prefix_lists` - prefix list.
      (선택) `security_groups` - Security Group ID 리스트.
      (선택) `self` - self 보안그룹을 추가할 것인지 여부.
  EOF

  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    description = optional(string, "")
    ingress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })), []
    )
    egress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })), []
    )
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(선택) load balancer 에 추가할 security group 리스트."
  type        = list(string)
  default     = []
  nullable    = false
}
