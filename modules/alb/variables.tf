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
}

variable "network_mapping" {
  description = <<EOF
  (선택) load balancer 에 IP 주소 설정. 서브넷의 대상으로 트래픽을 라우팅 `network_mapping` 블록 내용.
    (필수) `subnet` - load balancer 에 연결할 서브넷 ID 각 영역당 하나의 서브넷만 할당 가능.
  EOF
  type = map(object({
    subnet = string
  }))
  default  = {}
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

###################################################
# Listener
###################################################
ariable "listeners" {
  description = <<EOF
  (선택) load balancer 리스너 목록 입니다. `listener` 블록 내용.
    (필수) `port` - load balancer 리스너 포트 정보.
    (필수) `protocol` - load balancer 리스너 protocol 정보. 가능 한 값`HTTP` and `HTTPS`.
    (필수) `default_action_type` - 리스너 default action 에 대한 정보 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`.
    (선택) `default_action_parameters` - default action 에 대한 파타미터 정보 `default_action_parameters` 블록 내용.
      (선택) `order` - 작업에 대한 순서 between `1` and `50000`.
      (선택) `target_group` - 리스너에 매핑시킬 target group 이름.
      (선택) `status_code` - 고정 응답에 대한 status code. `2XX`, `4XX`, `5XX. `default_action_type` 이 `FIXED_RESPONSE` 일때만 설정.
      (선택) `content_type` - 응답에 대한 `Content-Type`. `text/plain`, `text/css`, `text/html`, `application/javascript`, `application/json`. `default_action_type` 이 `FIXED_RESPONSE` 일때만 설정. 
      (선택) `data` - Body 메세지 설정. `default_action_type` 이 `FIXED_RESPONSE` 일때만 설정.
      (선택) `protocol` - 리다이렉션 Url 프로토콜. `HTTP`, `HTTPS`, or `#{protocol}`. Defaults: `#{protocol}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
      (선택) `host` - 리다이렉션 Url 호스트 이름. Defaults: `#{host}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
      (선택) `port` - 리다이렉션 Url 포트 정보 `1` to `65535` or `#{port}`. Defaults: `#{port}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
      (선택) `path` - 리다이렉션 Url 패스 정보 `/`. 다음 값이 포함 가능.`#{host}`, `#{path}`, and `#{port}`. Defaults: `/#{path}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
      (선택) `query` - 리다이렉션 Url 쿼리 변수가 필요한 경우 설정. Defaults: `#{query}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
      (선택) `target_group` - Target Group 에 대한 이름. `default_action_type` 이 `WEIGHTED_FORWARD`, `FORWARD` 일때만 설정.
      (선택) `authentication_request_extra_params` - 인증 끝점에 대한 리다이렉션 요청에 포함할 쿼리 변수. `default_action_type` 이 `AUTHENTICATE_OIDC`, `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `on_unauthenticated_request` - 사용자가 인증되지 않을경우의 동작. 유효값 `deny`, `allow` Default: `deny`. `default_action_type` 이 `AUTHENTICATE_OIDC`, `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `scope` - IdP 에서 요청할 사용자 클레임 집합. `default_action_type` 이 `AUTHENTICATE_COGNITO` 일때만 설정
      (선택) `session_cookie_name` - 세션정보를 유지하는데 사용되는 쿠키 이름. `default_action_type` 이 `AUTHENTICATE_OIDC`, `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `session_timeout` - 인증 최대 세션 시간(초). `default_action_type` 이 `AUTHENTICATE_OIDC`, `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `user_pool_arn` - Cognoto 사용자 풀 ARN. `default_action_type` 이 `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `user_pool_client_id` - Cognoto 사용자 풀 클라이언트 ID. `default_action_type` 이 `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `user_pool_domain` -  Cognoto 사용자 풀 도메인. `default_action_type` 이 `AUTHENTICATE_COGNITO` 일때만 설정.
      (선택) `authorization_endpoint` - IdP 승인 끝점. `default_action_type` 이 `AUTHENTICATE_OIDC` 일때만 설정.
      (선택) `client_id` - OAuth 2.0 클라이언트 식별자. `default_action_type` 이 `AUTHENTICATE_OIDC` 일때만 설정.
      (선택) `client_secret` - OAuth 2.0 클라이언트 비밀번호. `default_action_type` 이 `AUTHENTICATE_OIDC` 일때만 설정.
      (선택) `issuer` - IdP 의 OIDC 발급 식별자. `default_action_type` 이 `AUTHENTICATE_OIDC` 일때만 설정.
      (선택) `token_endpoint` - IdP 의 토큰 엔드포인트. `default_action_type` 이 `AUTHENTICATE_OIDC` 일때만 설정.
      (선택) `user_info_endpoint` - IdP 사용자 정보 엔드포인트. `default_action_type` 이 `AUTHENTICATE_OIDC` 일때만 설정.
      (필수) `tagets` - target group 리스트. `targets` 블록 내용. `default_action_type` 이 `FORWARD`, `WEIGHTED_FORWARD` 일때만 설정.
        (필수) `target_group` - 리스너에 매핑시킬 target group 이름.
        (선택) `weight` - target group 에 대한 traffic weight `0` 부터 `999` 설정 가능. Default: `1`.
      (선택) `stickiness_duration` - 규칙의 대상 그룹으로 고정으로 라우팅 되기 위한 설정. `0` 부터 `604800` 설정가능. Default: `0`. `default_action_type` 이 `WEIGHTED_FORWARD` 일때만 설정.
    (선택) `rules` - 리스너에 정의되는 규칙에 따라 로드 밸런서가 하나 이상의 대상 그룹에 있는 대상으로 요청을 라우팅하는 방법 `rules` 블록 내용.
      (필수) `priority` - rule 에 대한 우선순위 값 설정`1` 부터 `50000` 까지 설정 가능.
      (필수) `conditions` - 규칙에 대한 조건. 하나이상의 조건블록을 여러번 설정 할수 있으며 `HTTP_HEADER` 와 `QUERY` 를 제외하고 대부분 규칙당 하나. `conditions` 블록 내용.
        (필수) `type` - 규칙에 대한 type. 다음 과 같은 설정 가능 `HOST`, `HTTP_METHOD`, `HTTP_HEADER`, `PATH`, `QUERY`, `SOURCE_IP`.
        (선택) `name` - 검색할 HTTP 헤더의 이름. 최대크기는 40자, 비교는 대소문자 구분하지 않고 RFC7240 문자만 지원하며, 와일드 카드는 지원하지 않음. `type` 이 `HTTP_HEADER` 일때만 설정.
        (필수) `values` for `HOST` - 일치시킬 호스트 헤더 패턴의 목록.
        (필수) `values` for `HTTP_METHOD` - 일치시킬 HTTP 요청 메서드 또는 동사 목록.
        (필수) `values` for `HTTP_HEADER` - 일치시킬 HTTP 헤더 목록.
        (필수) `values` for `PATH` - 요청 URL 과 일치시킬 경로 패턴 목록.
        (필수) `values` for `QUERY` - 일치시킬 쿼리 문자열 쌍 목록.
        (필수) `values` for `SOURCE_IP` -일치시킬 IP CIDR 목록.
      (필수) `action_type` - 라우팅 작업에 대한 유형 `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`.
      (선택) `action_parameters` - default action 에 대한 파타미터 정보 `default_action_parameters`.
        (선택) `target_group` - 리스너에 매핑시킬 target group 이름.
        (선택) `status_code` - 고정 응답에 대한 status code. `2XX`, `4XX`, `5XX. `default_action_type` 이 `FIXED_RESPONSE` 일때만 설정.
        (선택) `content_type` - 응답에 대한 `Content-Type`. `text/plain`, `text/css`, `text/html`, `application/javascript`, `application/json`. `default_action_type` 이 `FIXED_RESPONSE` 일때만 설정. 
        (선택) `data` - Body 메세지 설정. `default_action_type` 이 `FIXED_RESPONSE` 일때만 설정.
        (선택) `protocol` - 리다이렉션 Url 프로토콜. `HTTP`, `HTTPS`, or `#{protocol}`. Defaults: `#{protocol}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
        (선택) `host` - 리다이렉션 Url 호스트 이름. Defaults: `#{host}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
        (선택) `port` - 리다이렉션 Url 포트 정보 `1` to `65535` or `#{port}`. Defaults: `#{port}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
        (선택) `path` - 리다이렉션 Url 패스 정보 `/`. 다음 값이 포함 가능.`#{host}`, `#{path}`, and `#{port}`. Defaults: `/#{path}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
        (선택) `query` - 리다이렉션 Url 쿼리 변수가 필요한 경우 설정. Defaults: `#{query}`. `default_action_type` 이 `REDIRECT_301` or `REDIRECT_302` 일때만 설정.
        (선택) `target_group` - Target Group 에 대한 이름. `default_action_type` 이 `WEIGHTED_FORWARD`, `FORWARD` 일때만 설정.
        (필수) `tagets` - target group 리스트. `targets` 블록 내용. `default_action_type` 이 `FORWARD`, `WEIGHTED_FORWARD` 일때만 설정.
          (필수) `target_group` - 리스너에 매핑시킬 target group 이름.
          (선택) `weight` - target group 에 대한 traffic weight `0` 부터 `999` 설정 가능. Default: `1`.
      (선택) `stickiness_duration` - 규칙의 대상 그룹으로 고정으로 라우팅 되기 위한 설정. `0` 부터 `604800` 설정가능. Default: `0`. `default_action_type` 이 `WEIGHTED_FORWARD` 일때만 설정.
    (선택) `tls` - The configuration for TLS listener of the load balancer. 필수 if `protocol` is `HTTPS`. `tls` block as defined below.
      (선택) `certificate` - SSL certificate arn.
      (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.
      (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`.
  EOF
  type        = any
  default     = []
  nullable    = false
}

###################################################
# Target Group(s)
###################################################
variable "target_groups" {
  description = <<EOF
  (선택) target group 에 대한 Map 리스트 정보. `target_groups` 블록 내용
    (필수) `target_type` - target group 에 대한 type. 다음 중 선택 가능 `lambda`, `ip`, `instance`.
    (선택) `ip_address_type` - target group 에서 사용하는 IP 주소 유형. 다음중 선택 가능 `ipv4`, `ipv6`. `target_type` 이 `ip` 일때만 설정.
    (선택) `port` - 대상에 대한 수신 포트. `target_type` 이 `instance`, `ip` 일때만 설정.
    (선택) `protocol` - 대상에 대한 수신 프로토콜. 다음중 선택 가능 `TCP`, `HTTP`, `HTTPS` `target_type` 이 `instance`, `ip` 일때만 설정.
    (선택) `deregistration_delay` - 대상에 대한 드레에닝 설정. `0` 부터 `3600`(초) 설정 가능. Default: 300
    (선택) `slow_start` - 대상그룹 워밍업되는 시간. `30` 부터 `900`(초) Default: `0`
    (선택) `load_balancing_algorithm_type` - 로드밸런서가 대상을 선택하는 방법. 다음중 선택 `round_robin`, `least_outstanding_requests`, `weighted_random`. Default: `least_outstanding_requests`
    (선택) `lambda_multi_value_headers_enabled` - 로드밸런서와 Lambda 간에 교환되는 요청 및 응답헤더 값에 문자열 배열이 포함되는지 여부. Default: `false`. `target_type` 이 `lambda` 일때만 설정.
    (선택) `load_balancing_anomaly_mitigation` - 대상 그룹 이상 징후 완화 활성화 여부. 다음중 선택 가능 `on`, `off`. `load_balancing_algorithm_type` 이 `weighted_random` 일때만 설정.
    (선택) `load_balancing_cross_zone_enabled` - 교차 영역 로드밸런서 활성화 여부. 다음중 선택 가능 `ture`, `false`, `use_load_balancer_configuration` Default: `use_load_balancer_configuration`
    (선택) `protocol_version` - 프로토콜 버전 설정.
    (선택) `preserve_client_ip` - 클라이언트 IP 보존 활성화 여부. 문서 참고 `https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html#client-ip-preservation`
    (선택) `health_check` - 타겟 그룹에 타겟에 대한 health check 정보. `health_check` 블록 내용.
      (선택) `enabled` - health check 를 활성화에 대한 여부.
      (선택) `healthy_threshold` - 정상으로 간주하기 위한 연속 상태 확인 성공 횟수. `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.
      (선택) `interval` - 대상 확인에 대한 상태 확인 시간(초). `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.
      (선택) `matcher` - 대상에 대한 성공 코드. `200,202` or `200-299` 와 같이 설정 가능. GRPC 의 경우 `0` 부터 `99` 설정. `HTTP`, `HTTPS` 의 경우 `200` 부터 `499` 까지 설정.
      (선택) `path` - 상태 요청에 대한 path.
      (선택) `port` - 상태 확인에 대한 port 정보. `traffic-port`, `1` 에서 `65546` 까지 설정 가능.
      (선택) `protocol` - 상태 검사에 대한 protocol.
      (선택) `timeout` - 대상으로 부터 응답이 없으면 상태 확인 실패 의미하는 시간(초). `2` 부터 `120` 까지 설정 가능.
      (선택) `unhealthy_threshold` - 비정상으로 간주하기 위한 연속 상태 확인 실패 횟수. `2` 부터 `10` 까지 설정가능.
    (선택) `stickiness` - 고정된 세션 구성. `stickiness` 블록 내용.
      (선택) `type` - sticky session 타입. 다음 중 설정 가능 `lb_cookie`, `app_cookie`. Default: `lb_cookie`
      (선택) `cookie_duration` - `lb_cookie` type 에만 설정 가능. 동일 대상으로 라우팅 되어야하는 시간(초). `1` 부터 `604800` 까지 설정 가능.
      (선택) `stickiness_cookie` - Application 기반 쿠키의 이름. `AWSALB`, `AWSALBAPP`, `AWSALBTG` 는 접두사 예약이 되어 있으므로 사용 불가. `app_cookie` 유형일 경우 사용.
      (선택) `enabled` - sticky session 활성화 여부. Default: `false`
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
  type        = any
  default     = {}
  nullable    = false
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

