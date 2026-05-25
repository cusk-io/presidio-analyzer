# AWS Access Key detection
POST http://{{base_url}}/analyze
{
    "text": "AKIAIOSFODNN7EXAMPLE",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].entity_type" == "AWS_ACCESS_KEY"
jsonpath "$[0].score" >= 0.8


# AWS Secret Key detection
POST http://{{base_url}}/analyze
{
    "text": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].entity_type" == "AWS_SECRET_KEY"
jsonpath "$[0].score" >= 0.6


# Both keys in context
POST http://{{base_url}}/analyze
{
    "text": "AKIAIOSFODNN7EXAMPLE and wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count >= 2
jsonpath "$[*].entity_type" contains "AWS_ACCESS_KEY"
jsonpath "$[*].entity_type" contains "AWS_SECRET_KEY"
