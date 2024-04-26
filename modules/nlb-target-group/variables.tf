variable "name" {
  description = "(필수) target group 이름."
  type        = string
  nullable    = false
}

variable "vpc_id" {
  description = "(필수) target group 이 생성 될 VPC ID."
  type        = string
  nullable    = false
}

variable "target_type" {
  description = "(필수) target group 에 대한 type. 다음 중 선택 가능 `alb`, `ip`, `instance`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["alb", "ip", "instance"], var.target_type)
    error_message = "다음중 하나를 선택 해야 합니다. `alb`, `ip`, `instance`"
  }
}

variable "ip_address_type" {
  description = "(선택) target group 에서 사용하는 IP 주소 유형. 다음중 선택 가능 `ipv4`, `ipv6`. `target_type` 이 `ip` 일때만 설정."
  type        = string
  default     = null
}

variable "port" {
  description = "(선택) 대상에 대한 수신 포트. `target_type` 이 `instance`, `ip` 일때만 설정. 가능 하며 다음중 선택 가능. `1-65535`."
  type        = number
  default     = null
}

variable "protocol" {
  description = "(선택) 대상에 대한 수신 프로토콜. 다음중 선택 가능 `TCP`, `TLS`, `UDP`, `TCP_UDP`. `target_type` 이 `instance`, `ip` 일때만 설정."
  type        = string
  default     = null
}

variable "proxy_protocol_v2" {
  description = "(선택) 프록시 프로토콜v2 에 대한 지원 활성화 여부. Default: `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "preserve_client_ip" {
  description = <<EOF
  (선택) 클라이언트 IP 보존 활성화 여부. `Default: null`.
    `values` for `target_type` 이 `instance` 일때 Default: `true`.
    `values` for `target_type` 이 `ip` 이며, `protocol` 이 `UDP`, `TCP_UDP` 일때 Default: `true`.
    `values` for `target_type` 이 `ip` 이며, `protocol` 이 `TCP`, `TLS` 일때 Default: `false`
  EOF
  type        = bool
  default     = null
}

variable "connection_termination" {
  description = "(선택) 등록시간이 초과되면 연결을 종료할지 여부. Default: `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "deregistration_delay" {
  description = "(선택) 대상에 대한 드레에닝 설정. `0` 부터 `3600`(초) 설정 가능. Default: 300"
  type        = number
  default     = 300
  nullable    = false

  validation {
    condition = alltrue([
      var.deregistration_delay >= 0,
      var.deregistration_delay <= 3600
    ])
    error_message = "다음중 하나를 선택 해야 합니다. `0-3600`"
  }
}

variable "stickiness_enabled" {
  description = "(선택) sticky session 활성화 여부."
  type        = bool
  default     = false
  nullable    = false
}

variable "health_check" {
  description = <<EOF
  (선택) `health_check` - 타겟 그룹에 타겟에 대한 health check 정보. `health_check` 블록 내용.
    (선택) `enabled` - health check 를 활성화에 대한 여부.
    (선택) `healthy_threshold` - 정상으로 간주하기 위한 연속 상태 확인 성공 횟수. `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.
    (선택) `interval` - 대상 확인에 대한 상태 확인 시간(초). `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.
    (선택) `matcher` - 대상에 대한 성공 코드. `200,202` or `200-299` 와 같이 설정 가능. GRPC 의 경우 `0` 부터 `99` 설정. `HTTP`, `HTTPS` 의 경우 `200` 부터 `499` 까지 설정.
    (선택) `path` - 상태 요청에 대한 path. Default: `/`
    (선택) `port` - 상태 확인에 대한 port 정보. `traffic-port`, `1` 에서 `65546` 까지 설정 가능.
    (선택) `protocol` - 상태 검사에 대한 protocol.
    (선택) `timeout` - 대상으로 부터 응답이 없으면 상태 확인 실패 의미하는 시간(초). `2` 부터 `120` 까지 설정 가능.
    (선택) `unhealthy_threshold` - 비정상으로 간주하기 위한 연속 상태 확인 실패 횟수. `2` 부터 `10` 까지 설정가능.
  EOF
  type = object({
    enabled  = optional(bool, true)
    protocol = optional(string, null)
    port     = optional(number, null)
    path     = optional(string, null)
    matcher  = optional(string, null)

    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    interval            = optional(number, 30)
    timeout             = optional(number, 5)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      length(var.health_check.path) <= 1024,
      var.health_check.healthy_threshold <= 10,
      var.health_check.healthy_threshold >= 2,
      var.health_check.unhealthy_threshold <= 10,
      var.health_check.unhealthy_threshold >= 2,
      var.health_check.interval >= 5,
      var.health_check.interval <= 300,
      var.health_check.timeout >= 2,
      var.health_check.timeout <= 120,
    ])
    error_message = "`health_check` 설정값이 잘못 되었습니다.."
  }
}

variable "targets" {
  description = <<EOF
  (선택) 대상 그룹에 추가할 대상 집합. `targets` 블록 내용.
    (필수) `target_id` - 대상에 대한 ID 값.
    (선택) `port` - 대상에 대한 port.
    (선택) `availability_zone` - 대상에 대한 zone 영역.
  EOF
  type = map(object({
    target_id         = optional(string)
    port              = optional(number, null)
    availability_zone = optional(string, null)
  }))
}

variable "tags" {
  description = "(선택) 리소스 태그 내용"
  type        = map(string)
  default     = {}
}
