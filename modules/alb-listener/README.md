# alb-listener

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
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_action_parameters"></a> [default\_action\_parameters](#input\_default\_action\_parameters) | (선택) default action 에 대한 파타미터 정보 `default_action_parameters` 블록 내용.<br>    (선택) `order` - 작업에 대한 순서 between `1` and `50000`.<br>    (선택) `status_code` - 고정 응답에 대한 status code. `2XX`, `4XX`, `5XX. `default\_action\_type` 이 `FIXED\_RESPONSE` 일때만 설정.<br>    (선택) `content\_type` - 응답에 대한 `Content-Type`. `text/plain`, `text/css`, `text/html`, `application/javascript`, `application/json`. `default\_action\_type` 이 `FIXED\_RESPONSE` 일때만 설정.<br>    (선택) `data` - Body 메세지 설정. `default\_action\_type` 이 `FIXED\_RESPONSE` 일때만 설정.<br>    (선택) `protocol` - 리다이렉션 Url 프로토콜. `HTTP`, `HTTPS`, or `#{protocol}`. Defaults: `#{protocol}`. `default\_action\_type` 이 `REDIRECT\_301` or `REDIRECT\_302` 일때만 설정.<br>    (선택) `host` - 리다이렉션 Url 호스트 이름. Defaults: `#{host}`. `default\_action\_type` 이 `REDIRECT\_301` or `REDIRECT\_302` 일때만 설정.<br>    (선택) `port` - 리다이렉션 Url 포트 정보 `1` to `65535` or `#{port}`. Defaults: `#{port}`. `default\_action\_type` 이 `REDIRECT\_301` or `REDIRECT\_302` 일때만 설정.<br>    (선택) `path` - 리다이렉션 Url 패스 정보 `/`. 다음 값이 포함 가능.`#{host}`, `#{path}`, and `#{port}`. Defaults: `/#{path}`. `default\_action\_type` 이 `REDIRECT\_301` or `REDIRECT\_302` 일때만 설정.<br>    (선택) `query` - 리다이렉션 Url 쿼리 변수가 필요한 경우 설정. Defaults: `#{query}`. `default\_action\_type` 이 `REDIRECT\_301` or `REDIRECT\_302` 일때만 설정.<br>    (선택) `target\_group` - Target Group 에 대한 이름. `default\_action\_type` 이 `WEIGHTED\_FORWARD`, `FORWARD` 일때만 설정.<br>    (선택) `authentication\_request\_extra\_params` - 인증 끝점에 대한 리다이렉션 요청에 포함할 쿼리 변수. `default\_action\_type` 이 `AUTHENTICATE\_OIDC`, `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `on\_unauthenticated\_request` - 사용자가 인증되지 않을경우의 동작. 유효값 `deny`, `allow` Default: `deny`. `default\_action\_type` 이 `AUTHENTICATE\_OIDC`, `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `scope` - IdP 에서 요청할 사용자 클레임 집합. `default\_action\_type` 이 `AUTHENTICATE\_COGNITO` 일때만 설정<br>    (선택) `session\_cookie\_name` - 세션정보를 유지하는데 사용되는 쿠키 이름. `default\_action\_type` 이 `AUTHENTICATE\_OIDC`, `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `session\_timeout` - 인증 최대 세션 시간(초). `default\_action\_type` 이 `AUTHENTICATE\_OIDC`, `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `user\_pool\_arn` - Cognoto 사용자 풀 ARN. `default\_action\_type` 이 `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `user\_pool\_client\_id` - Cognoto 사용자 풀 클라이언트 ID. `default\_action\_type` 이 `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `user\_pool\_domain` -  Cognoto 사용자 풀 도메인. `default\_action\_type` 이 `AUTHENTICATE\_COGNITO` 일때만 설정.<br>    (선택) `authorization\_endpoint` - IdP 승인 끝점. `default\_action\_type` 이 `AUTHENTICATE\_OIDC` 일때만 설정.<br>    (선택) `client\_id` - OAuth 2.0 클라이언트 식별자. `default\_action\_type` 이 `AUTHENTICATE\_OIDC` 일때만 설정.<br>    (선택) `client\_secret` - OAuth 2.0 클라이언트 비밀번호. `default\_action\_type` 이 `AUTHENTICATE\_OIDC` 일때만 설정.<br>    (선택) `issuer` - IdP 의 OIDC 발급 식별자. `default\_action\_type` 이 `AUTHENTICATE\_OIDC` 일때만 설정.<br>    (선택) `token\_endpoint` - IdP 의 토큰 엔드포인트. `default\_action\_type` 이 `AUTHENTICATE\_OIDC` 일때만 설정.<br>    (선택) `user\_info\_endpoint` - IdP 사용자 정보 엔드포인트. `default\_action\_type` 이 `AUTHENTICATE\_OIDC` 일때만 설정.<br>    (필수) `targets` - target group 리스트. `targets` 블록 내용. `default\_action\_type` 이 `FORWARD`, `WEIGHTED\_FORWARD` 일때만 설정.<br>      (필수) `target\_group` - 리스너에 매핑시킬 target group 이름.<br>      (선택) `weight` - target group 에 대한 traffic weight `0` 부터 `999` 설정 가능. Default: `1`.<br>    (선택) `stickiness\_duration` - 규칙의 대상 그룹으로 고정으로 라우팅 되기 위한 설정. `0` 부터 `604800` 설정가능. Default: `0`. `default\_action\_type` 이 `WEIGHTED\_FORWARD` 일때만 설정.<br>` | `any` | `{}` | no |
| <a name="input_default_action_type"></a> [default\_action\_type](#input\_default\_action\_type) | (필수) 리스너 default action 에 대한 정보 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`. | `string` | n/a | yes |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | (필수) listener 가 포함되어 있는 load balancer arn | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (필수) listener 수신 port. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (필수) listener 프로토콜. | `string` | n/a | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | (선택) 리스너에 정의되는 규칙에 따라 로드 밸런서가 하나 이상의 대상 그룹에 있는 대상으로 요청을 라우팅하는 방법 `rules` 블록 내용.<br>    (필수) `priority` - rule 에 대한 우선순위 값 설정`1` 부터 `50000` 까지 설정 가능.<br>    (필수) `conditions` - 규칙에 대한 조건. 하나이상의 조건블록을 여러번 설정 할수 있으며 `HTTP_HEADER` 와 `QUERY` 를 제외하고 대부분 규칙당 하나. `conditions` 블록 내용.<br>    (필수) `type` - 규칙에 대한 type. 다음 과 같은 설정 가능 `HOST`, `HTTP_METHOD`, `HTTP_HEADER`, `PATH`, `QUERY`, `SOURCE_IP`.<br>      (선택) `name` - 검색할 HTTP 헤더의 이름. 최대크기는 40자, 비교는 대소문자 구분하지 않고 RFC7240 문자만 지원하며, 와일드 카드는 지원하지 않음. `type` 이 `HTTP_HEADER` 일때만 설정.<br>      (필수) `values` for `HOST` - 일치시킬 호스트 헤더 패턴의 목록.<br>      (필수) `values` for `HTTP_METHOD` - 일치시킬 HTTP 요청 메서드 또는 동사 목록.<br>      (필수) `values` for `HTTP_HEADER` - 일치시킬 HTTP 헤더 목록.<br>      (필수) `values` for `PATH` - 요청 URL 과 일치시킬 경로 패턴 목록.<br>      (필수) `values` for `QUERY` - 일치시킬 쿼리 문자열 쌍 목록.<br>      (필수) `values` for `SOURCE_IP` -일치시킬 IP CIDR 목록.<br>    (필수) `action_type` - 라우팅 작업에 대한 유형 `FORWARD`, `WEIGHTED_FORWARD`, `AUTHENTICATE_COGNITO`, `AUTHENTICATE_OIDC`, `FIXED_RESPONSE`, `REDIRECT_301`, `REDIRECT_302`.<br>    (선택) `action_parameters` - `default_action_parameters` 와 동일. | `any` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (선택) 리소스 태그 내용 | `map(string)` | `{}` | no |
| <a name="input_tls"></a> [tls](#input\_tls) | (선택) TLS Listener 에 필요한 설정. `protocol` 이 `HTTPS` 일때 사용. `tls` 블록 내용.<br>    (선택) `certificate` - SSL certificate arn.<br>    (선택) `additional_certificates` - 리스너에 연결될 인증서 arn 세트.<br>    (선택) `security_policy` - SSL(Secure Socket Layer) 협상 구성에 대한 보안 정책의 이름. 프로토콜이 `HTTPS` 일때만 사용. Default: `ELBSecurityPolicy-2016-08`. | <pre>object({<br>    certificate             = optional(string)<br>    additional_certificates = optional(set(string), [])<br>    security_policy         = optional(string, "ELBSecurityPolicy-2016-08")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | listener arn |
| <a name="output_default_action"></a> [default\_action](#output\_default\_action) | listener default action 정보 |
| <a name="output_id"></a> [id](#output\_id) | listener id |
| <a name="output_port"></a> [port](#output\_port) | listener port |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | listener protocol |
| <a name="output_rules"></a> [rules](#output\_rules) | listener 추가 rules 정보 |
| <a name="output_tls"></a> [tls](#output\_tls) | listener TLS 정보 |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
