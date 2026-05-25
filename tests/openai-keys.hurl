# OpenAI sk-proj key
POST http://{{base_url}}/analyze
{
    "text": "sk-proj-abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOP",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].entity_type" == "OPENAI_API_KEY"
jsonpath "$[0].score" >= 0.8



# OpenAI sk-exp key
POST http://{{base_url}}/analyze
{
    "text": "sk-Exp-abcdefghijklmnopqrstuvwxyz1234567890",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].entity_type" == "OPENAI_API_KEY"



# Anthropic key (sk-ant-)
POST http://{{base_url}}/analyze
{
    "text": "sk-ant-api03-abcdefghijklmnopqrstuvwxyz1234567890",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$[*].entity_type" contains "OPENAI_API_KEY"



# In context
POST http://{{base_url}}/analyze
{
    "text": "OPENAI_API_KEY=sk-proj-abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOP",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$[*].entity_type" contains "OPENAI_API_KEY"