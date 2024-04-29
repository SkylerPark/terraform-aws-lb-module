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
# Application Load Balancer
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

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "다음 중 설정 가능 합니다. `ipv4`, `dualstack`"
  }
}

variable "network_mapping" {
  description = <<EOF
  (선택) load balancer 에 IP 주소 설정. 서브넷의 대상으로 트래픽을 라우팅 `network_mapping` 블록 내용.
    (필수) `subnet` - load balancer 에 연결할 서브넷 ID 각 영역당 하나의 서브넷만 할당 가능.
  EOF
  type = list(object({
    subnet = string
  }))
  default  = []
  nullable = false
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

variable "connection_log" {
  description = <<EOF
  (선택) connaction log 에 대한 설정. `connection_log` 블록 내용.
    (선택) `enabled` - connaction log 를 활성화 할지에 대한 여부 Default: `false`.
    (선택) `bucket` - connaction log 를 적재할 버킷명.
    (선택) `prefix` - connaction log 를 적재할 버킷 prefix.
  EOF
  type = object({
    enabled = optional(bool, false)
    bucket  = optional(string)
    prefix  = optional(string)
  })
  default  = {}
  nullable = false
}

variable "desync_mitigation_mode" {
  description = "(선택) HTTP 비동기화로 인해 보안 위험을 처리하는 방법 유효 값 `defensive`, `strictest`, `monitor`. Defaults: `defensive`."
  type        = string
  default     = "defensive"
  nullable    = false

  validation {
    condition     = contains(["defensive", "strictest", "monitor"], var.desync_mitigation_mode)
    error_message = "다음중 하나의 값으로 설정 가능 합니다. `defensive`, `strictest`, `monitor`."
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

variable "http2_enabled" {
  description = "(선택) HTTP/2 활성화 여부. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

variable "waf_fail_open_enabled" {
  description = "(선택) WAF 지원 로드밸런서가 요청을 대상으로 라우팅하도록 허용할지 여부. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

variable "idle_timeout" {
  description = "(선택) 연결 유휴 상태를 허용 하는 시간(초) Default: `60`"
  type        = number
  default     = 60
  nullable    = false
}

variable "preserve_host_header" {
  description = "(선택) HTTP 요청 헤더를 보존하고 변경없이 대상으로 보낼지 여부. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

variable "drop_invalid_header_fields" {
  description = "(선택) 유효하지 않는 헤더가 들어왓을시, 제거 할지에 대한 여부. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

variable "tls_negotiation_headers_enabled" {
  description = "(선택) 협상된 TLS 버전 및 암호 제품에 대한 정보를 보내기전 클라이언트 요청에 추가 할지 여부. Default: `false`"
  type        = bool
  default     = false
  nullable    = false
}

variable "xff_header" {
  description = <<EOF
  (선택) xff header 설정값. `xff_header` 블록 내용.
    (선택) `mode` - 요청을 대상으로 보내기전 `X-Forwarded-For` 헤더를 수정. 가능 한 값 `append`, `preserve`, `remove`. Defaults to `append`.
      `append` - 클라이언트 IP 주소를 `X-Forwarded-For` 헤더에 추가.
      `preserve` - 클라이언트 IP 주소를 유지.
      `remove` -  `X-Forwarded-For` 헤더를 제거.
    (선택) `client_port_preservation_enabled` - `X-Forwarded-For` 헤더가 클라이언트가 load balancer 에 연결하는데 사용한 소스 포트를 보존해야 하는지 여부. Default: `false`.
  EOF
  type = object({
    mode                             = optional(string, "append")
    client_port_preservation_enabled = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["append", "preserve", "remove"], var.xff_header.mode)
    error_message = "`xff_header.mode` 는 다음 값을 지원 합니다. `append`, `preserve`, `remove`."
  }
}

variable "security_groups" {
  description = "(선택) load balancer 에 추가할 security group 리스트."
  type        = list(string)
  default     = []
  nullable    = false
}

###################################################
# Listener(s)
###################################################
variable "listeners" {
  description = <<EOF
  (선택) load balancer 리스너 목록 입니다. `listeners` 블록 내용.
    (필수) `port` - load balancer 리스너 포트 정보.
    (필수) `protocol` - load balancer 리스너 protocol 정보. 가능 한 값`HTTP` and `HTTPS`.
    (필수) `default_action_type` - 리스너 default action 에 대한 정보 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`.
    (선택) `default_action_parameters` - default action 에 대한 파타미터 정보.
    (선택) `rules` - 리스너에 정의되는 규칙에 따라 로드 밸런서가 하나 이상의 대상 그룹에 있는 대상으로 요청을 라우팅하는 방법을 정의.
    (선택) `tls` - TLS Listener 에 필요한 설정. `protocol` 이 `HTTPS` 일때 사용. `tls` 블록 내용.
      (선택) `certificate` - SSL certificate arn.
      (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.
      (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`.
  EOF
  type        = any
  default     = []
  nullable    = false
}
