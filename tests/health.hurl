GET http://{{base_url}}/health
HTTP 200
[Asserts]
jsonpath "$.status" == "UP"