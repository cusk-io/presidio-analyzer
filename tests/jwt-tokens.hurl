# JWT token (3 segments, eyJ header)
POST http://{{base_url}}/analyze
{
    "text": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].entity_type" == "JWT_TOKEN"
jsonpath "$[0].score" >= 0.6



# Bearer token style
POST http://{{base_url}}/analyze
{
    "text": "eyJhbGciOiJIUzI1J9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tIn0.abc123signature",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].entity_type" == "JWT_TOKEN"



# JWT in context
POST http://{{base_url}}/analyze
{
    "text": "BEARER_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tIn0.abc123signature",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$[*].entity_type" contains "JWT_TOKEN"