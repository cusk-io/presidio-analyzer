# --- NEGATIVE CASES: strings that should NOT trigger detections ---

# Email incomplete (no domain)
POST http://{{base_url}}/analyze
{
    "text": "jameswatson@",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "EMAIL_ADDRESS"

---

# Email no local part
POST http://{{base_url}}/analyze
{
    "text": "@example.com",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "EMAIL_ADDRESS"

---

# Phone too short
POST http://{{base_url}}/analyze
{
    "text": "555-12",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "PHONE_NUMBER"

---

# Not a phone
POST http://{{base_url}}/analyze
{
    "text": "123",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "PHONE_NUMBER"

---

# Invalid IP octet
POST http://{{base_url}}/analyze
{
    "text": "256.1.1.1",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "IP_ADDRESS"

---

# Out of range IP octets
POST http://{{base_url}}/analyze
{
    "text": "999.999.999.999",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "IP_ADDRESS"

---

# AWS key wrong prefix
POST http://{{base_url}}/analyze
{
    "text": "BKIAIOSFODNN7EXAMPLE",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "AWS_ACCESS_KEY"

---

# GitHub token too short
POST http://{{base_url}}/analyze
{
    "text": "ghp_short",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "GITHUB_TOKEN"

---

# OpenAI key too short
POST http://{{base_url}}/analyze
{
    "text": "sk-short",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "OPENAI_API_KEY"

---

# JWT only 2 segments (no signature)
POST http://{{base_url}}/analyze
{
    "text": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "JWT_TOKEN"

---

# Private key no content
POST http://{{base_url}}/analyze
{
    "text": "-----BEGIN PRIVATE KEY-----",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "PRIVATE_KEY"

---

# Connection string no credentials
POST http://{{base_url}}/analyze
{
    "text": "mysql://user@host",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "CONNECTION_STRING"

---

# Connection string empty password
POST http://{{base_url}}/analyze
{
    "text": "mysql://user:@host",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "CONNECTION_STRING"

---

# Connection string no credentials at all
POST http://{{base_url}}/analyze
{
    "text": "mongodb://host",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "CONNECTION_STRING"

---

# SQL Server no password
POST http://{{base_url}}/analyze
{
    "text": "Server=myServerAddress;User Id=myUsername;",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" notContains "CONNECTION_STRING"