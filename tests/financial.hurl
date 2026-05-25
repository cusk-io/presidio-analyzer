# Credit card Visa (test number)
POST http://{{base_url}}/analyze
{
    "text": "4111-1111-1111-1111",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "CREDIT_CARD"

---

# Credit card Mastercard (test number)
POST http://{{base_url}}/analyze
{
    "text": "5500-0000-0000-0004",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "CREDIT_CARD"

---

# IBAN Germany
POST http://{{base_url}}/analyze
{
    "text": "DE89370400440532013000",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "IBAN"

---

# IBAN UK
POST http://{{base_url}}/analyze
{
    "text": "GB29NWBK60161331926819",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "IBAN"

---

# IPv4 address
POST http://{{base_url}}/analyze
{
    "text": "192.168.1.100",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "IP_ADDRESS"

---

# IPv6 address
POST http://{{base_url}}/analyze
{
    "text": "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    "language": "en"
}
HTTP 200
[Asserts]
jsonpath "$.entities[*].entity_type" contains "IP_ADDRESS"