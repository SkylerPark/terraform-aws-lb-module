variable "load_balancer" {
  description = "(필수) listener 가 포함되어 있는 load balancer arn"
  type        = string
  nullable    = false
}

variable "port" {
  description = "(필수) listener 수신 port."
  type        = number
  nullable    = false
}

variable "protocol" {
  description = "(필수) listener 프로토콜."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "다음중 하나를 선택 해야 합니다. `HTTP` and `HTTPS`."
  }
}

variable "default_action_type" {
  description = "(필수) 리스너 default action 에 대한 정보 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["FORWARD", "WEIGHTED_FORWARD", "FIXED_RESPONSE", "REDIRECT_301", "REDIRECT_302", "AUTHENTICATE_COGNITO", "AUTHENTICATE_OIDC"], var.default_action_type)
    error_message = "다음중 하나를 선택 해야 합니다. `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`."
  }
}

variable "default_action_parameters" {
  description = <<EOF
  (선택) default action 에 대한 파타미터 정보 `default_action_parameters` 블록 내용.
    (선택) `order` - 작업에 대한 순서 between `1` and `50000`.
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
    (필수) `targets` - target group 리스트. `targets` 블록 내용. `default_action_type` 이 `FORWARD`, `WEIGHTED_FORWARD` 일때만 설정.
      (필수) `target_group` - 리스너에 매핑시킬 target group 이름.
      (선택) `weight` - target group 에 대한 traffic weight `0` 부터 `999` 설정 가능. Default: `1`.
    (선택) `stickiness_duration` - 규칙의 대상 그룹으로 고정으로 라우팅 되기 위한 설정. `0` 부터 `604800` 설정가능. Default: `0`. `default_action_type` 이 `WEIGHTED_FORWARD` 일때만 설정.
  EOF
  type        = any
  default     = {}
  nullable    = false
}

variable "rules" {
  description = <<EOF
  (선택) 리스너에 정의되는 규칙에 따라 로드 밸런서가 하나 이상의 대상 그룹에 있는 대상으로 요청을 라우팅하는 방법 `rules` 블록 내용.
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
    (필수) `action_type` - 라우팅 작업에 대한 유형 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`.
    (선택) `action_parameters` - `default_action_parameters` 와 동일.
  EOF
  type        = any
  default     = []

  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        rule.priority >= 1,
        rule.priority <= 50000,
        length(rule.conditions) >= 1,
        length(rule.conditions) <= 5,
        alltrue([
          for condition in rule.conditions :
          alltrue([
            contains(["HOST", "HTTP_METHOD", "HTTP_HEADER", "PATH", "QUERY", "SOURCE_IP"], condition.type),
            length(condition.values) >= 1,
            length(condition.values) <= 5,
          ])
        ]),
        contains(["FORWARD", "WEIGHTED_FORWARD", "FIXED_RESPONSE", "REDIRECT_301", "REDIRECT_302", "AUTHENTICATE_COGNITO", "AUTHENTICATE_OIDC"], rule.action_type)
      ])
    ])
    error_message = "`rules` 설정에 대한 parameter 가 잘못 되었습니다."
  }
}

variable "tls" {
  description = <<EOF
  (선택) TLS Listener 에 필요한 설정. `protocol` 이 `HTTPS` 일때 사용. `tls` 블록 내용.
    (선택) `certificate` - SSL certificate arn.
    (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.
    (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`.
  EOF
  type = object({
    certificate             = optional(string)
    additional_certificates = optional(set(string), [])
    security_policy         = optional(string, "ELBSecurityPolicy-2016-08")
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(선택) 리소스 태그 내용"
  type        = map(string)
  default     = {}
}
