# RSA Private Key
POST http://{{base_url}}/analyze
{
    "text": "-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBALRiMLAHudeSA2MFJqfnF7v2FnGpMVpz8tFAD4BNv7xZ3Z5Z5Z5Z5Z5Z5\nZ5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5\n-----END RSA PRIVATE KEY-----",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "PRIVATE_KEY"
jsonpath "$.entities[0].score" >= 0.9

---

# EC Private Key
POST http://{{base_url}}/analyze
{
    "text": "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEIOv1fCsE9QSmXjP7v8YKjXvN6LqH3Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5\n-----END EC PRIVATE KEY-----",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "PRIVATE_KEY"

---

# OPENSSH Private Key
POST http://{{base_url}}/analyze
{
    "text": "-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn\nNhAAAAAwEAAQAAAQEAq1vO3u5S8J6LQ9Z5s5H5JZ5k5Z5k5Z5k5Z5k5Z5k5Z5k5Z5k5Z5k5\n-----END OPENSSH PRIVATE KEY-----",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "PRIVATE_KEY"