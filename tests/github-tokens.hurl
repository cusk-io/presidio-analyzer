# GitHub Personal Access Token (classic)
POST http://{{base_url}}/analyze
{
    "text": "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "GITHUB_TOKEN"
jsonpath "$.entities[0].score" >= 0.8

---

# GitHub Fine-grained PAT
POST http://{{base_url}}/analyze
{
    "text": "github_pat_11AAAAAAAAAA0_0123456789abcdefghijklmnopqrst",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count >= 1
jsonpath "$.entities[0].entity_type" == "GITHUB_TOKEN"

---

# GitHub OAuth (gho_)
POST http://{{base_url}}/analyze
{
    "text": "gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities" count == 1
jsonpath "$.entities[0].entity_type" == "GITHUB_TOKEN"

---

# In context
POST http://{{base_url}}/analyze
{
    "text": "GH_TOKEN=ghp_abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnop",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "GITHUB_TOKEN"