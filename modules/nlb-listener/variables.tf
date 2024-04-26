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
    condition     = contains(["TCP", "TCP_UDP", "TLS"], var.protocol)
    error_message = "다음중 하나를 선택 해야 합니다. `TCP`, `TCP_UDP`, `TLS`."
  }
}

variable "tls" {
  description = <<EOF
  (선택) TLS Listener 에 필요한 설정. `protocol` 이 `HTTPS` 일때 사용. `tls` 블록 내용.
    (선택) `certificate` - SSL certificate arn.
    (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.
    (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`.
    (선택) `alpn_policy` - Application-Layer Protocol Negotiation (ALPN) 정책. ALPN 는 TLS hello message 교환 시 프로토콜 협상을 포함시키는 TLS 확장. `protocol` 이 `TLS` 일때 사용. 다음과 같은 설정이 가능 `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, `None`. Default: `None`.
  EOF
  type = object({
    certificate             = optional(string)
    additional_certificates = optional(set(string), [])
    security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    alpn_policy             = optional(string, "None")
  })
  default  = {}
  nullable = false
}

variable "target_group" {
  description = "(필수) Target Group 에 대한 arn."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "(선택) 리소스 태그 내용"
  type        = map(string)
  default     = {}
}
