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
