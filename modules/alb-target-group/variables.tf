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
  description = "(필수) target group 에 대한 type. 다음 중 선택 가능 `lambda`, `ip`, `instance`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["lambda", "ip", "instance"], var.target_type)
    error_message = "다음중 하나를 선택 해야 합니다. `lambda`, `ip`, `instance`"
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
  description = "(선택) 대상에 대한 수신 프로토콜. 다음중 선택 가능 `TCP`, `HTTP`, `HTTPS` `target_type` 이 `instance`, `ip` 일때만 설정."
  type        = string
  default     = null
}

variable "deregistration_delay" {
  description = "(선택) 대상에 대한 드레에닝 설정. `0` 부터 `3600`(초) 설정 가능. Default: `300`"
  type        = number
  default     = 300
  nullable    = false

  validation {
    condition = alltrue([
      var.deregistration_delay >= 0,
      var.deregistration_delay <= 3600
    ])
    error_message = "다음중 하나를 선택 해야합니다. `1-3600`"
  }
}

variable "load_balancing_algorithm_type" {
  description = "(선택) 로드밸런서가 대상을 선택하는 방법. 다음중 선택 `round_robin`, `least_outstanding_requests`, `weighted_random`. Default: `round_robin`"
  type        = string
  default     = "round_robin"
  nullable    = false

  validation {
    condition     = contains(["round_robin", "least_outstanding_requests", "weighted_random"], var.load_balancing_algorithm_type)
    error_message = "다음중 하나를 선택 해야합니다. `round_robin`, `least_outstanding_requests`, `weighted_random`"
  }
}

variable "slow_start" {
  description = "(선택) 대상그룹 워밍업되는 시간. `30` 부터 `900`(초) Default: `0`"
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition = alltrue([
      var.slow_start >= 30,
      var.slow_start <= 300
    ]) || var.slow_start == 0 ? true : false
    error_message = "다음 중 하나를 선택 해야 합니다. `0` or `30-900`"
  }
}

variable "lambda_multi_value_headers_enabled" {
  description = "(선택) 로드밸런서와 Lambda 간에 교환되는 요청 및 응답헤더 값에 문자열 배열이 포함되는지 여부. Default: `false`. `target_type` 이 `lambda` 일때만 설정."
  type        = bool
  default     = false
  nullable    = false
}

variable "load_balancing_anomaly_mitigation_enabled" {
  description = "(선택) 대상 그룹 이상 징후 완화 활성화 여부. 다음중 선택 가능 `true` - `on`, `false` - `off`. `load_balancing_algorithm_type` 이 `weighted_random` 일때만 설정."
  type        = bool
  default     = false
  nullable    = false
}

variable "load_balancing_cross_zone_enabled" {
  description = "(선택) 교차 영역 로드밸런서 활성화 여부. 다음중 선택 가능 `true`, `false`, `use_load_balancer_configuration` Default: `use_load_balancer_configuration`"
  type        = string
  default     = "use_load_balancer_configuration"
  nullable    = false

  validation {
    condition     = contains(["true", "false", "use_load_balancer_configuration"], var.load_balancing_cross_zone_enabled)
    error_message = "다음 중 하나를 선택 해야 합니다. `true`, `false`,`use_load_balancer_configuration`"
  }
}

variable "protocol_version" {
  description = "(선택) 대상 그룹에 대한 프로토콜 버전"
  type        = string
  default     = "HTTP1"
  nullable    = false

  validation {
    condition     = contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "다음 중 하나를 선택 해야 합니다. `HTTP1`, `HTTP2` and `GRPC`."
  }
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

variable "stickiness" {
  description = <<EOF
  (선택) 고정된 세션 구성. `stickiness` 블록 내용.
    (선택) `enabled` - sticky session 활성화 여부. Default: `false`
    (선택) `type` - sticky session 타입. 다음 중 설정 가능 `lb_cookie`, `app_cookie`. Default: `lb_cookie`
    (선택) `cookie_duration` - `lb_cookie` type 에만 설정 가능. 동일 대상으로 라우팅 되어야하는 시간(초). `1` 부터 `604800` 까지 설정 가능.
    (선택) `stickiness_cookie` - Application 기반 쿠키의 이름. `AWSALB`, `AWSALBAPP`, `AWSALBTG` 는 접두사 예약이 되어 있으므로 사용 불가. `app_cookie` 유형일 경우 사용.
  EOF
  type = object({
    enabled           = optional(bool, false)
    type              = optional(string, "lb_cookie")
    cookie_duration   = optional(number, null)
    stickiness_cookie = optional(string, null)
  })
  nullable = false

  validation {
    condition = var.stickiness.enabled ? (
      alltrue([
        contains(["lb_cookie", "app_cookie"], var.stickiness.type),
        var.stickiness.type == "lb_cookie" ? alltrue([var.stickiness.cookie_duration >= 1, var.stickiness.cookie_duration <= 604800]) : true,
        var.stickiness.type == "app_cookie" ? contains(["AWSALB", "AWSALBAPP", "AWSALBTG"], var.stickiness.stickiness_cookie) ? true : false : true
      ])
    ) : true
    error_message = "`stickiness` 설정값이 잘못 되었습니다."
  }
}

variable "targets" {
  description = <<EOF
  (선택) 대상 그룹에 추가할 대상 집합. `targets` 블록 내용.
    (필수) `target_id` - 대상에 대한 ID 값.
    (선택) `port` - 대상에 대한 port.
    (선택) `availability_zone` - 대상에 대한 zone 영역.
    (선택) `lambda_function_name` - lambda function name. `target_type` 이 `lambda` 일 경우에 사용.
    (선택) `lambda_qualifier` - unique statement. `target_type` 이 `lambda` 일 경우에 사용.
    (선택) `lambda_action` - lambda 액션. `target_type` 이 `lambda` 일 경우에 사용.
    (선택) `lambda_principal` - lambda 권한을 받는 주체 - `target_type` 이 `lambda` 일 경우에 사용.
    (선택) `lambda_source_account` - lambda source account ID - `target_type` 이 `lambda` 일 경우에 사용.
    (선택) `lambda_event_source_token` - lambda event token - `target_type` 이 `lambda` 일 경우에 사용.
  EOF
  type = map(object({
    target_id                 = optional(string)
    port                      = optional(number, null)
    availability_zone         = optional(string, null)
    lambda_function_name      = optional(string, null)
    lambda_qualifier          = optional(string, null)
    lambda_action             = optional(string, "lambda:InvokeFunction")
    lambda_principal          = optional(string, "elasticloadbalancing.amazonaws.com")
    lambda_source_account     = optional(string, null)
    lambda_event_source_token = optional(string, null)
  }))
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(선택) 리소스 태그 내용"
  type        = map(string)
  default     = {}
}
