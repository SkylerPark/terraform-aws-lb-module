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
    (선택) `private_ipv4_address` -
    (선택) `ipv6_address` - 
    (선택) `elastic_ip` - 
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
