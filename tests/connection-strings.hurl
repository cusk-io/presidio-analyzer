# PostgreSQL URL-format
POST http://{{base_url}}/analyze
{
    "text": "postgres://adminuser:MySecretPass@db.example.com:5432/mydb",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"
jsonpath "$.entities[0].score" >= 0.7

---

# MySQL URL-format
POST http://{{base_url}}/analyze
{
    "text": "mysql://root:password123@mysql.example.com:3306/production",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# MongoDB SRV
POST http://{{base_url}}/analyze
{
    "text": "mongodb+srv://admin:password123@cluster0.mongodb.net/admin",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# Redis with TLS
POST http://{{base_url}}/analyze
{
    "text": "rediss://default:myredispass@redis.internal:6380/1",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# SQL Server OLEDB format
POST http://{{base_url}}/analyze
{
    "text": "Server=myServer;User Id=myUser;Password=mySecret;",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# SSH user@host
POST http://{{base_url}}/analyze
{
    "text": "ssh root@192.168.1.100",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# SSH with protocol prefix
POST http://{{base_url}}/analyze
{
    "text": "ssh://deployuser:deploy_secret@git.internal:2222/~/repo",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# HTTP Basic Auth URL
POST http://{{base_url}}/analyze
{
    "text": "https://admin:admin123@api.example.com/v1/users",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"

---

# Password-only basic auth
POST http://{{base_url}}/analyze
{
    "text": "https://:secret_token@registry.example.com/v2/",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "CONNECTION_STRING"