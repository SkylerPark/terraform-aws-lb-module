# nlb-target-group

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
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connection_termination"></a> [connection\_termination](#input\_connection\_termination) | (선택) 등록시간이 초과되면 연결을 종료할지 여부. Default: `false`. | `bool` | `false` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (선택) 대상에 대한 드레에닝 설정. `0` 부터 `3600`(초) 설정 가능. Default: 300 | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (선택) `health_check` - 타겟 그룹에 타겟에 대한 health check 정보. `health_check` 블록 내용.<br>    (선택) `enabled` - health check 를 활성화에 대한 여부.<br>    (선택) `healthy_threshold` - 정상으로 간주하기 위한 연속 상태 확인 성공 횟수. `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.<br>    (선택) `interval` - 대상 확인에 대한 상태 확인 시간(초). `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.<br>    (선택) `matcher` - 대상에 대한 성공 코드. `200,202` or `200-299` 와 같이 설정 가능. GRPC 의 경우 `0` 부터 `99` 설정. `HTTP`, `HTTPS` 의 경우 `200` 부터 `499` 까지 설정.<br>    (선택) `path` - 상태 요청에 대한 path. Default: `/`<br>    (선택) `port` - 상태 확인에 대한 port 정보. `traffic-port`, `1` 에서 `65546` 까지 설정 가능.<br>    (선택) `protocol` - 상태 검사에 대한 protocol.<br>    (선택) `timeout` - 대상으로 부터 응답이 없으면 상태 확인 실패 의미하는 시간(초). `2` 부터 `120` 까지 설정 가능.<br>    (선택) `unhealthy_threshold` - 비정상으로 간주하기 위한 연속 상태 확인 실패 횟수. `2` 부터 `10` 까지 설정가능. | <pre>object({<br>    enabled  = optional(bool, true)<br>    protocol = optional(string, null)<br>    port     = optional(number, null)<br>    path     = optional(string, null)<br>    matcher  = optional(string, null)<br><br>    healthy_threshold   = optional(number, 5)<br>    unhealthy_threshold = optional(number, 2)<br>    interval            = optional(number, 30)<br>    timeout             = optional(number, 5)<br>  })</pre> | `{}` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (선택) target group 에서 사용하는 IP 주소 유형. 다음중 선택 가능 `ipv4`, `ipv6`. `target_type` 이 `ip` 일때만 설정. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (필수) target group 이름. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (선택) 대상에 대한 수신 포트. `target_type` 이 `instance`, `ip` 일때만 설정. 가능 하며 다음중 선택 가능. `1-65535`. | `number` | `null` | no |
| <a name="input_preserve_client_ip"></a> [preserve\_client\_ip](#input\_preserve\_client\_ip) | (선택) 클라이언트 IP 보존 활성화 여부. `Default: null`.<br>    `values` for `target_type` 이 `instance` 일때 Default: `true`.<br>    `values` for `target_type` 이 `ip` 이며, `protocol` 이 `UDP`, `TCP_UDP` 일때 Default: `true`.<br>    `values` for `target_type` 이 `ip` 이며, `protocol` 이 `TCP`, `TLS` 일때 Default: `false` | `bool` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (선택) 대상에 대한 수신 프로토콜. 다음중 선택 가능 `TCP`, `TLS`, `UDP`, `TCP_UDP`. `target_type` 이 `instance`, `ip` 일때만 설정. | `string` | `null` | no |
| <a name="input_proxy_protocol_v2"></a> [proxy\_protocol\_v2](#input\_proxy\_protocol\_v2) | (선택) 프록시 프로토콜v2 에 대한 지원 활성화 여부. Default: `false`. | `bool` | `false` | no |
| <a name="input_stickiness_enabled"></a> [stickiness\_enabled](#input\_stickiness\_enabled) | (선택) sticky session 활성화 여부. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (선택) 리소스 태그 내용 | `map(string)` | `{}` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | (필수) target group 에 대한 type. 다음 중 선택 가능 `alb`, `ip`, `instance`. | `string` | n/a | yes |
| <a name="input_targets"></a> [targets](#input\_targets) | (선택) 대상 그룹에 추가할 대상 집합. `targets` 블록 내용.<br>    (필수) `target_id` - 대상에 대한 ID 값.<br>    (선택) `port` - 대상에 대한 port.<br>    (선택) `availability_zone` - 대상에 대한 zone 영역. | <pre>map(object({<br>    target_id         = optional(string)<br>    port              = optional(number, null)<br>    availability_zone = optional(string, null)<br>  }))</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (필수) target group 이 생성 될 VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | target group arn |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | target group 에 attribute 값 |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | target group health check 값 |
| <a name="output_id"></a> [id](#output\_id) | target group id |
| <a name="output_name"></a> [name](#output\_name) | target group 이름 |
| <a name="output_port"></a> [port](#output\_port) | target group port |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | target group protocol |
| <a name="output_protocol_version"></a> [protocol\_version](#output\_protocol\_version) | target group protocol version |
| <a name="output_targets"></a> [targets](#output\_targets) | target group 에 포함 된 정보 리스트 |
| <a name="output_type"></a> [type](#output\_type) | target group type |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
