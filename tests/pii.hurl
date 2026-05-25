# Email addresses
POST http://{{base_url}}/analyze
{
    "text": "jameswatson2312@gmail.com",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count >= 1
jsonpath "$[*].entity_type" contains "EMAIL_ADDRESS"



POST http://{{base_url}}/analyze
{
    "text": "admin+secret@example.org",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count >= 1
jsonpath "$[*].entity_type" contains "EMAIL_ADDRESS"



# US Phone number
POST http://{{base_url}}/analyze
{
    "text": "+1 (555) 123-4567",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$" count >= 1
jsonpath "$[*].entity_type" contains "PHONE_NUMBER"



# UK Phone number
POST http://{{base_url}}/analyze
{
    "text": "+44 20 7946 0958",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$[*].entity_type" contains "PHONE_NUMBER"



# Names (depends on context, may not always trigger)
POST http://{{base_url}}/analyze
{
    "text": "James Watson contacted John Smith about the project",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$[*].entity_type" contains "PERSON"