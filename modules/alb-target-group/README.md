# alb-target-group

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
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (선택) 대상에 대한 드레에닝 설정. `0` 부터 `3600`(초) 설정 가능. Default: `300` | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (선택) `health_check` - 타겟 그룹에 타겟에 대한 health check 정보. `health_check` 블록 내용.<br>    (선택) `enabled` - health check 를 활성화에 대한 여부.<br>    (선택) `healthy_threshold` - 정상으로 간주하기 위한 연속 상태 확인 성공 횟수. `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.<br>    (선택) `interval` - 대상 확인에 대한 상태 확인 시간(초). `5` 부터 `300` 설정 가능. `lambda`의 경우 `lambda` 만 설정.<br>    (선택) `matcher` - 대상에 대한 성공 코드. `200,202` or `200-299` 와 같이 설정 가능. GRPC 의 경우 `0` 부터 `99` 설정. `HTTP`, `HTTPS` 의 경우 `200` 부터 `499` 까지 설정.<br>    (선택) `path` - 상태 요청에 대한 path. Default: `/`<br>    (선택) `port` - 상태 확인에 대한 port 정보. `traffic-port`, `1` 에서 `65546` 까지 설정 가능.<br>    (선택) `protocol` - 상태 검사에 대한 protocol.<br>    (선택) `timeout` - 대상으로 부터 응답이 없으면 상태 확인 실패 의미하는 시간(초). `2` 부터 `120` 까지 설정 가능.<br>    (선택) `unhealthy_threshold` - 비정상으로 간주하기 위한 연속 상태 확인 실패 횟수. `2` 부터 `10` 까지 설정가능. | <pre>object({<br>    enabled  = optional(bool, true)<br>    protocol = optional(string, null)<br>    port     = optional(number, null)<br>    path     = optional(string, null)<br>    matcher  = optional(string, null)<br><br>    healthy_threshold   = optional(number, 5)<br>    unhealthy_threshold = optional(number, 2)<br>    interval            = optional(number, 30)<br>    timeout             = optional(number, 5)<br>  })</pre> | `{}` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (선택) target group 에서 사용하는 IP 주소 유형. 다음중 선택 가능 `ipv4`, `ipv6`. `target_type` 이 `ip` 일때만 설정. | `string` | `null` | no |
| <a name="input_lambda_multi_value_headers_enabled"></a> [lambda\_multi\_value\_headers\_enabled](#input\_lambda\_multi\_value\_headers\_enabled) | (선택) 로드밸런서와 Lambda 간에 교환되는 요청 및 응답헤더 값에 문자열 배열이 포함되는지 여부. Default: `false`. `target_type` 이 `lambda` 일때만 설정. | `bool` | `false` | no |
| <a name="input_load_balancing_algorithm_type"></a> [load\_balancing\_algorithm\_type](#input\_load\_balancing\_algorithm\_type) | (선택) 로드밸런서가 대상을 선택하는 방법. 다음중 선택 `round_robin`, `least_outstanding_requests`, `weighted_random`. Default: `round_robin` | `string` | `"round_robin"` | no |
| <a name="input_load_balancing_anomaly_mitigation_enabled"></a> [load\_balancing\_anomaly\_mitigation\_enabled](#input\_load\_balancing\_anomaly\_mitigation\_enabled) | (선택) 대상 그룹 이상 징후 완화 활성화 여부. 다음중 선택 가능 `true` - `on`, `false` - `off`. `load_balancing_algorithm_type` 이 `weighted_random` 일때만 설정. | `bool` | `false` | no |
| <a name="input_load_balancing_cross_zone_enabled"></a> [load\_balancing\_cross\_zone\_enabled](#input\_load\_balancing\_cross\_zone\_enabled) | (선택) 교차 영역 로드밸런서 활성화 여부. 다음중 선택 가능 `true`, `false`, `use_load_balancer_configuration` Default: `use_load_balancer_configuration` | `string` | `"use_load_balancer_configuration"` | no |
| <a name="input_name"></a> [name](#input\_name) | (필수) target group 이름. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (선택) 대상에 대한 수신 포트. `target_type` 이 `instance`, `ip` 일때만 설정. 가능 하며 다음중 선택 가능. `1-65535`. | `number` | `null` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (선택) 대상에 대한 수신 프로토콜. 다음중 선택 가능 `TCP`, `HTTP`, `HTTPS` `target_type` 이 `instance`, `ip` 일때만 설정. | `string` | `null` | no |
| <a name="input_protocol_version"></a> [protocol\_version](#input\_protocol\_version) | (선택) 대상 그룹에 대한 프로토콜 버전 | `string` | `"HTTP1"` | no |
| <a name="input_slow_start"></a> [slow\_start](#input\_slow\_start) | (선택) 대상그룹 워밍업되는 시간. `30` 부터 `900`(초) Default: `0` | `number` | `0` | no |
| <a name="input_stickiness"></a> [stickiness](#input\_stickiness) | (선택) 고정된 세션 구성. `stickiness` 블록 내용.<br>    (선택) `enabled` - sticky session 활성화 여부. Default: `false`<br>    (선택) `type` - sticky session 타입. 다음 중 설정 가능 `lb_cookie`, `app_cookie`. Default: `lb_cookie`<br>    (선택) `cookie_duration` - `lb_cookie` type 에만 설정 가능. 동일 대상으로 라우팅 되어야하는 시간(초). `1` 부터 `604800` 까지 설정 가능.<br>    (선택) `stickiness_cookie` - Application 기반 쿠키의 이름. `AWSALB`, `AWSALBAPP`, `AWSALBTG` 는 접두사 예약이 되어 있으므로 사용 불가. `app_cookie` 유형일 경우 사용. | <pre>object({<br>    enabled           = optional(bool, false)<br>    type              = optional(string, "lb_cookie")<br>    cookie_duration   = optional(number, null)<br>    stickiness_cookie = optional(string, null)<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (선택) 리소스 태그 내용 | `map(string)` | `{}` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | (필수) target group 에 대한 type. 다음 중 선택 가능 `lambda`, `ip`, `instance`. | `string` | n/a | yes |
| <a name="input_targets"></a> [targets](#input\_targets) | (선택) 대상 그룹에 추가할 대상 집합. `targets` 블록 내용.<br>    (필수) `target_id` - 대상에 대한 ID 값.<br>    (선택) `port` - 대상에 대한 port.<br>    (선택) `availability_zone` - 대상에 대한 zone 영역.<br>    (선택) `lambda_function_name` - lambda function name. `target_type` 이 `lambda` 일 경우에 사용.<br>    (선택) `lambda_qualifier` - unique statement. `target_type` 이 `lambda` 일 경우에 사용.<br>    (선택) `lambda_action` - lambda 액션. `target_type` 이 `lambda` 일 경우에 사용.<br>    (선택) `lambda_principal` - lambda 권한을 받는 주체 - `target_type` 이 `lambda` 일 경우에 사용.<br>    (선택) `lambda_source_account` - lambda source account ID - `target_type` 이 `lambda` 일 경우에 사용.<br>    (선택) `lambda_event_source_token` - lambda event token - `target_type` 이 `lambda` 일 경우에 사용. | <pre>map(object({<br>    target_id                 = optional(string)<br>    port                      = optional(number, null)<br>    availability_zone         = optional(string, null)<br>    lambda_function_name      = optional(string, null)<br>    lambda_qualifier          = optional(string, null)<br>    lambda_action             = optional(string, "lambda:InvokeFunction")<br>    lambda_principal          = optional(string, "elasticloadbalancing.amazonaws.com")<br>    lambda_source_account     = optional(string, null)<br>    lambda_event_source_token = optional(string, null)<br>  }))</pre> | `{}` | no |
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
