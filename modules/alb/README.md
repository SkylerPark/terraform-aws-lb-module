# alb

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_listener"></a> [listener](#module\_listener) | ../alb-listener | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | git::https://github.com/SkylerPark/terraform-aws-vpc-module.git//modules/security-group/ | tags/1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log"></a> [access\_log](#input\_access\_log) | (선택) access log 에 대한 설정. `access_log` 블록 내용.<br>    (선택) `enabled` - access log 를 활성화 할지에 대한 여부 Default: `false`.<br>    (선택) `bucket` - access log 를 적재할 버킷명.<br>    (선택) `prefix` - access log 를 적재할 버킷 prefix. | <pre>object({<br>    enabled = optional(bool, false)<br>    bucket  = optional(string)<br>    prefix  = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_connection_log"></a> [connection\_log](#input\_connection\_log) | (선택) connaction log 에 대한 설정. `connection_log` 블록 내용.<br>    (선택) `enabled` - connaction log 를 활성화 할지에 대한 여부 Default: `false`.<br>    (선택) `bucket` - connaction log 를 적재할 버킷명.<br>    (선택) `prefix` - connaction log 를 적재할 버킷 prefix. | <pre>object({<br>    enabled = optional(bool, false)<br>    bucket  = optional(string)<br>    prefix  = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_cross_zone_load_balancing_enabled"></a> [cross\_zone\_load\_balancing\_enabled](#input\_cross\_zone\_load\_balancing\_enabled) | (선택) 영역 간 로드밸런싱 활성화 여부. Default: `true` | `bool` | `true` | no |
| <a name="input_default_security_group"></a> [default\_security\_group](#input\_default\_security\_group) | (선택) load balancer 에 추가 security group 설정. `security_group` 블록 내용.<br>    (필수) `enabled` - security group 을 생성 할지 여부 Default: false<br>    (선택) `name` - security group 이름 설정하지 않으면, load balancer 의 이름으로 설정<br>    (선택) 수신에 대한 설정 `ingress_rules` 블록 내용.<br>      (필수) `id` - 수신 규칙의 ID 입니다 이값은 Terraform 코드 내에서만 사용.<br>      (선택) `description` - 규칙에 대한 설명.<br>      (필수) `protocol` - 규칙에 대한 protocol. `protocol` 이 `-1` 로 됫을댄 모든 프로토콜 모든 포트범위로 되며, `from_port` `to_port` 값은 정의 불가.<br>      (필수) `from_port` - 포트 범위의 시작 TCP, UDP protocols, or ICMP/ICMPv6 type.<br>      (필수) `to_port` - 포트 범위의 끝 TCP and UDP protocols, or an ICMP/ICMPv6 type.<br>      (선택) `ipv4_cidrs` - IPv4 에 대한 CIDR 리스트.<br>      (선택) `ipv6_cidrs` - IPv6에 대한 CIDR 리스트.<br>      (선택) `prefix_lists` - prefix list.<br>      (선택) `security_groups` - Security Group ID 리스트.<br>      (선택) `self` - self 보안그룹을 추가할 것인지 여부.<br>    (선택) `egress_rules` - security group 송신 정책 map<br>      (필수) `id` - 송신 규칙의 ID 입니다 이값은 Terraform 코드 내에서만 사용.<br>      (선택) `description` - 규칙에 대한 설명.<br>      (필수) `protocol` - 규칙에 대한 protocol. `protocol` 이 `-1` 로 됫을댄 모든 프로토콜 모든 포트범위로 되며, `from_port` `to_port` 값은 정의 불가.<br>      (필수) `from_port` - 포트 범위의 시작 TCP, UDP protocols, or ICMP/ICMPv6 type.<br>      (필수) `to_port` - 포트 범위의 끝 TCP and UDP protocols, or an ICMP/ICMPv6 type.<br>      (선택) `ipv4_cidrs` - IPv4 에 대한 CIDR 리스트.<br>      (선택) `ipv6_cidrs` - IPv6에 대한 CIDR 리스트.<br>      (선택) `prefix_lists` - prefix list.<br>      (선택) `security_groups` - Security Group ID 리스트.<br>      (선택) `self` - self 보안그룹을 추가할 것인지 여부. | <pre>object({<br>    enabled     = optional(bool, true)<br>    name        = optional(string)<br>    description = optional(string, "")<br>    ingress_rules = optional(<br>      list(object({<br>        id              = string<br>        description     = optional(string, "")<br>        protocol        = string<br>        from_port       = number<br>        to_port         = number<br>        ipv4_cidrs      = optional(list(string), [])<br>        ipv6_cidrs      = optional(list(string), [])<br>        prefix_lists    = optional(list(string), [])<br>        security_groups = optional(list(string), [])<br>        self            = optional(bool, false)<br>      })), []<br>    )<br>    egress_rules = optional(<br>      list(object({<br>        id              = string<br>        description     = optional(string, "")<br>        protocol        = string<br>        from_port       = number<br>        to_port         = number<br>        ipv4_cidrs      = optional(list(string), [])<br>        ipv6_cidrs      = optional(list(string), [])<br>        prefix_lists    = optional(list(string), [])<br>        security_groups = optional(list(string), [])<br>        self            = optional(bool, false)<br>      })), []<br>    )<br>  })</pre> | `{}` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | (선택) AWS API 를 통해 삭제 할지 여부 `true` 인 경우 비활성화. Default: `false` | `bool` | `false` | no |
| <a name="input_desync_mitigation_mode"></a> [desync\_mitigation\_mode](#input\_desync\_mitigation\_mode) | (선택) HTTP 비동기화로 인해 보안 위험을 처리하는 방법 유효 값 `defensive`, `strictest`, `monitor`. Defaults: `defensive`. | `string` | `"defensive"` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | (선택) 유효하지 않는 헤더가 들어왓을시, 제거 할지에 대한 여부. Default: `false` | `bool` | `false` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | (선택) HTTP/2 활성화 여부. Default: `false` | `bool` | `false` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | (선택) 연결 유휴 상태를 허용 하는 시간(초) Default: `60` | `number` | `60` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (선택) load balancer 의 서브넷에서 사용하는 IP 주소 유형. 가능한 값 `ipv4` or `dualstack` Default: `ipv4` | `string` | `"ipv4"` | no |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public) | (필수) load balancer 가 public 으로 할당할지 여부 Default: `true` | `bool` | `true` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | (선택) load balancer 리스너 목록 입니다. `listeners` 블록 내용.<br>    (필수) `port` - load balancer 리스너 포트 정보.<br>    (필수) `protocol` - load balancer 리스너 protocol 정보. 가능 한 값`HTTP` and `HTTPS`.<br>    (필수) `default_action_type` - 리스너 default action 에 대한 정보 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`.<br>    (선택) `default_action_parameters` - default action 에 대한 파타미터 정보.<br>    (선택) `rules` - 리스너에 정의되는 규칙에 따라 로드 밸런서가 하나 이상의 대상 그룹에 있는 대상으로 요청을 라우팅하는 방법을 정의.<br>    (선택) `tls` - TLS Listener 에 필요한 설정. `protocol` 이 `HTTPS` 일때 사용. `tls` 블록 내용.<br>      (선택) `certificate` - SSL certificate arn.<br>      (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.<br>      (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`. | `any` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (필수) load balancer 이름. | `string` | n/a | yes |
| <a name="input_network_mapping"></a> [network\_mapping](#input\_network\_mapping) | (선택) load balancer 에 IP 주소 설정. 서브넷의 대상으로 트래픽을 라우팅 `network_mapping` 블록 내용.<br>    (필수) `subnet` - load balancer 에 연결할 서브넷 ID 각 영역당 하나의 서브넷만 할당 가능. | <pre>list(object({<br>    subnet = string<br>  }))</pre> | `[]` | no |
| <a name="input_preserve_host_header"></a> [preserve\_host\_header](#input\_preserve\_host\_header) | (선택) HTTP 요청 헤더를 보존하고 변경없이 대상으로 보낼지 여부. Default: `false` | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (선택) load balancer 에 추가할 security group 리스트. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (선택) 리소스 태그 내용 | `map(string)` | `{}` | no |
| <a name="input_tls_negotiation_headers_enabled"></a> [tls\_negotiation\_headers\_enabled](#input\_tls\_negotiation\_headers\_enabled) | (선택) 협상된 TLS 버전 및 암호 제품에 대한 정보를 보내기전 클라이언트 요청에 추가 할지 여부. Default: `false` | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (필수) load balancer 가 생성 될 VPC ID | `string` | n/a | yes |
| <a name="input_waf_fail_open_enabled"></a> [waf\_fail\_open\_enabled](#input\_waf\_fail\_open\_enabled) | (선택) WAF 지원 로드밸런서가 요청을 대상으로 라우팅하도록 허용할지 여부. Default: `false` | `bool` | `false` | no |
| <a name="input_xff_header"></a> [xff\_header](#input\_xff\_header) | (선택) xff header 설정값. `xff_header` 블록 내용.<br>    (선택) `mode` - 요청을 대상으로 보내기전 `X-Forwarded-For` 헤더를 수정. 가능 한 값 `append`, `preserve`, `remove`. Defaults to `append`.<br>      `append` - 클라이언트 IP 주소를 `X-Forwarded-For` 헤더에 추가.<br>      `preserve` - 클라이언트 IP 주소를 유지.<br>      `remove` -  `X-Forwarded-For` 헤더를 제거.<br>    (선택) `client_port_preservation_enabled` - `X-Forwarded-For` 헤더가 클라이언트가 load balancer 에 연결하는데 사용한 소스 포트를 보존해야 하는지 여부. Default: `false`. | <pre>object({<br>    mode                             = optional(string, "append")<br>    client_port_preservation_enabled = optional(bool, false)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_log"></a> [access\_log](#output\_access\_log) | load balancer Access log 설정값 |
| <a name="output_arn"></a> [arn](#output\_arn) | load balancer ARN |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | load balancer ARN suffix |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | application load balancer attribute 값. |
| <a name="output_default_security_group"></a> [default\_security\_group](#output\_default\_security\_group) | load balancer 에 default security group ID. |
| <a name="output_domain"></a> [domain](#output\_domain) | load balancer DNS name. |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | load balancer IP Type. |
| <a name="output_is_public"></a> [is\_public](#output\_is\_public) | load balancer public 으로 할당중인지 여부 |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | load balancer listener 리스트 |
| <a name="output_name"></a> [name](#output\_name) | load balancer Name |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | load balancer security group Ids. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | load balancer 가 생성된 subnet IDs |
| <a name="output_type"></a> [type](#output\_type) | load balancer type |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | load balancer 가 생성된 VPC ID |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route53 별칭 레코드에 사용되는 load balancer 호스팅 영역 ID. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
