# nlb-listener

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | (필수) listener 가 포함되어 있는 load balancer arn | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (필수) listener 수신 port. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (필수) listener 프로토콜. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (선택) 리소스 태그 내용 | `map(string)` | `{}` | no |
| <a name="input_target_group"></a> [target\_group](#input\_target\_group) | (필수) Target Group 에 대한 arn. | `string` | n/a | yes |
| <a name="input_tls"></a> [tls](#input\_tls) | (선택) TLS Listener 에 필요한 설정. `protocol` 이 `HTTPS` 일때 사용. `tls` 블록 내용.<br>    (선택) `certificate` - SSL certificate arn.<br>    (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.<br>    (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`.<br>    (선택) `alpn_policy` - Application-Layer Protocol Negotiation (ALPN) 정책. ALPN 는 TLS hello message 교환 시 프로토콜 협상을 포함시키는 TLS 확장. `protocol` 이 `TLS` 일때 사용. 다음과 같은 설정이 가능 `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, `None`. Default: `None`. | <pre>object({<br>    certificate             = optional(string)<br>    additional_certificates = optional(set(string), [])<br>    security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")<br>    alpn_policy             = optional(string, "None")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | listener arn |
| <a name="output_default_actions"></a> [default\_actions](#output\_default\_actions) | listener default action 정보 |
| <a name="output_id"></a> [id](#output\_id) | listener id |
| <a name="output_port"></a> [port](#output\_port) | listener port |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | listener protocol |
| <a name="output_tls"></a> [tls](#output\_tls) | listener TLS 정보 |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
