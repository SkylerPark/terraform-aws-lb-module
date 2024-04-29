# nlb

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
| <a name="module_listener"></a> [listener](#module\_listener) | ../nlb-listener | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log"></a> [access\_log](#input\_access\_log) | (선택) access log 에 대한 설정. `access_log` 블록 내용.<br>    (선택) `enabled` - access log 를 활성화 할지에 대한 여부 Default: `false`.<br>    (선택) `bucket` - access log 를 적재할 버킷명.<br>    (선택) `prefix` - access log 를 적재할 버킷 prefix. | <pre>object({<br>    enabled = optional(bool, false)<br>    bucket  = optional(string)<br>    prefix  = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_cross_zone_load_balancing_enabled"></a> [cross\_zone\_load\_balancing\_enabled](#input\_cross\_zone\_load\_balancing\_enabled) | (선택) 영역 간 로드밸런싱 활성화 여부. Default: `true` | `bool` | `true` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | (선택) AWS API 를 통해 삭제 할지 여부 `true` 인 경우 비활성화. Default: `false` | `bool` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (선택) load balancer 의 서브넷에서 사용하는 IP 주소 유형. 가능한 값 `ipv4` or `dualstack` Default: `ipv4` | `string` | `"ipv4"` | no |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public) | (필수) load balancer 가 public 으로 할당할지 여부 Default: `true` | `bool` | `true` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | (선택) load balancer 리스너 목록 입니다. `listener` 블록 내용.<br>    (필수) `port` - load balancer 리스너 포트 정보.<br>    (필수) `protocol` - load balancer 리스너 protocol 정보. 가능 한 값 `TCP`, `TLS`, 'UDP', 'TCP\_UDP'.<br>    (필수) `target_group` - 리스너에 매핑시킬 target group 이름.<br>    (선택) `tls` - TLS Listener 에 필요한 설정. `protocol` 이 `TLS` 일때 사용. `tls` 블록 내용.<br>      (선택) `certificate` - SSL certificate arn.<br>      (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.<br>      (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때 사용. Default: `ELBSecurityPolicy-TLS13-1-2-2021-06`.<br>      (선택) `alpn_policy` - Application-Layer Protocol Negotiation (ALPN) 정책. ALPN 는 TLS hello message 교환 시 프로토콜 협상을 포함시키는 TLS 확장. `protocol` 이 `TLS` 일때 사용. 다음과 같은 설정이 가능 `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, `None`. Default: `None`. | <pre>list(object({<br>    port         = number<br>    protocol     = string<br>    target_group = string<br>    tls = optional(object({<br>      certificate             = optional(string)<br>      additional_certificates = optional(set(string), [])<br>      security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")<br>      alpn_policy             = optional(string, "None")<br>    }), {})<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (필수) load balancer 이름. | `string` | n/a | yes |
| <a name="input_network_mapping"></a> [network\_mapping](#input\_network\_mapping) | (선택) load balancer 에 IP 주소 설정. 서브넷의 대상으로 트래픽을 라우팅 `network_mapping` 블록 내용.<br>    (필수) `subnet` - load balancer 에 연결할 서브넷 ID 각 영역당 하나의 서브넷만 할당 가능.<br>    (선택) `private_ipv4_address` - 내부 load balancer 를 위한 Private IP 주소.<br>    (선택) `ipv6_address` - IPv6 주소,<br>    (선택) `elastic_ip` - 인터넷 연결 load balancer 에 대한 elastic\_ip 주소 | <pre>list(object({<br>    subnet               = string<br>    private_ipv4_address = optional(string)<br>    ipv6_address         = optional(string)<br>    elastic_ip           = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_route53_resolver_availability_zone_affinity"></a> [route53\_resolver\_availability\_zone\_affinity](#input\_route53\_resolver\_availability\_zone\_affinity) | (선택) load balancer 가용영역간에 트래픽이 분산되는 방식을 결정하는 구성. Resolver를 사용하여 로드 밸런서 DNS 이름을 확인하는 클라이언트에 대한 내부 요청에만 적용. 허용 값 `ANY`, `PARTIAL`, `ALL`. Default: `ANY`.<br>    `ANY` - 클라이언트 DNS 쿼리는 load balancer 가용 영역에서 정산적인 IP 주소를 확인.<br>    `PARTIAL` - 클라이언트 DNS 쿼리의 85% 는 자체 가용영역에 있는 load balancer IP 주소를 선호.<br>    `ALL` - 클라이언트 DNS 쿼리는 자체 가용 영역의 load balancer IP 주소를 선호. | `string` | `"ANY"` | no |
| <a name="input_security_group_evaluation_on_privatelink_enabled"></a> [security\_group\_evaluation\_on\_privatelink\_enabled](#input\_security\_group\_evaluation\_on\_privatelink\_enabled) | (선택) AWS PrivateLink 를 통해 NLB 로 전송되는 트래픽에 대한 인바운드 보안 그룹 규칙을 적용할지 여부. Default: `false` | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (선택) load balancer 에 추가할 security group 리스트. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (선택) 리소스 태그 내용 | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (필수) load balancer 가 생성 될 VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_log"></a> [access\_log](#output\_access\_log) | load balancer Access log 설정값 |
| <a name="output_arn"></a> [arn](#output\_arn) | load balancer ARN |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | load balancer ARN suffix |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | network load balancer attribute 값. |
| <a name="output_domain"></a> [domain](#output\_domain) | load balancer DNS name. |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | load balancer IP Type. |
| <a name="output_is_public"></a> [is\_public](#output\_is\_public) | load balancer public 으로 할당중인지 여부 |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | load balancer listener 정보 리스트 |
| <a name="output_name"></a> [name](#output\_name) | load balancer Name |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | load balancer security group Ids. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | load balancer 가 생성된 subnet IDs |
| <a name="output_type"></a> [type](#output\_type) | load balancer type |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | load balancer 가 생성된 VPC ID |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route53 별칭 레코드에 사용되는 load balancer 호스팅 영역 ID. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
