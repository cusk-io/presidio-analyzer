# AWS Access Key detection
POST http://{{base_url}}/analyze
{
    "text": "AKIAIOSFODNN7EXAMPLE",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "AWS_ACCESS_KEY"
jsonpath "$.entities[0].score" >= 0.8

---

# AWS Secret Key detection
POST http://{{base_url}}/analyze
{
    "text": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "AWS_SECRET_KEY"
jsonpath "$.entities[0].score" >= 0.6

---

# Both keys in context
POST http://{{base_url}}/analyze
{
    "text": "AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 2
jsonpath "$.entities[*].entity_type" contains "AWS_ACCESS_KEY"
jsonpath "$.entities[*].entity_type" contains "AWS_SECRET_KEY"