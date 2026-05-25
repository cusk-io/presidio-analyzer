#!/usr/bin/env python3
"""HTTP API integration tests for the custom Presidio analyzer.

DEPRECATED: These tests have been replaced by hurl test files in tests/.
Run with: hurl --test tests/
"""

import json
import sys
import urllib.request
import urllib.error


BASE_URL = "http://localhost:3000"


def post(path: str, body: dict) -> dict:
    req = urllib.request.Request(
        f"{BASE_URL}{path}",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read())


def check_health():
    print("=== /health ===")
    try:
        with urllib.request.urlopen(f"{BASE_URL}/health", timeout=5) as r:
            data = json.loads(r.read())
            print(f"  OK: {data}")
            return True
    except Exception as e:
        print(f"  FAIL: {e}")
        return False


def check_aws_access_key():
    print("=== AWS Access Key ===")
    text = "AKIAIOSFODNN7EXAMPLE"
    result = post("/analyze", {"text": text, "language": "en"})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "AWS_ACCESS_KEY"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_aws_secret_key():
    print("=== AWS Secret Key ===")
    text = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    result = post("/analyze", {"text": text, "language": "en"})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "AWS_SECRET_KEY"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_github_token():
    print("=== GitHub Token ===")
    text = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    result = post("/analyze", {"text": text, "language": "en"})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "GITHUB_TOKEN"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_openai_key():
    print("=== OpenAI API Key ===")
    text = "sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    result = post("/analyze", {"text": text, "language": "en"})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "OPENAI_API_KEY"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_private_key():
    print("=== Private Key ===")
    text = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQ...\n-----END RSA PRIVATE KEY-----"
    result = post("/analyze", {"text": text, "language": "en"})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "PRIVATE_KEY"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_jwt():
    print("=== JWT Token ===")
    text = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    result = post("/analyze", {"text": text, "language": "en"})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "JWT_TOKEN"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_connection_string_url():
    print("=== Connection String (URL format) ===")
    text = "postgres://admin:supersecret@db.example.com:5432/mydb"
    result = post("/analyze", {"text": text, "language": "en", "entities": ["CONNECTION_STRING"]})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "CONNECTION_STRING"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_connection_string_sqlserver():
    print("=== Connection String (SQL Server OLEDB) ===")
    text = "Server=myServer;User Id=myUser;Password=mySecret;"
    result = post("/analyze", {"text": text, "language": "en", "entities": ["CONNECTION_STRING"]})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "CONNECTION_STRING"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_connection_string_ssh():
    print("=== Connection String (SSH) ===")
    text = "ssh user@host.example.com"
    result = post("/analyze", {"text": text, "language": "en", "entities": ["CONNECTION_STRING"]})
    entities = result.get("entities", [])
    found = [e for e in entities if e.get("entity_type") == "CONNECTION_STRING"]
    if found:
        print(f"  OK — detected: {found}")
        return True
    print(f"  FAIL — got: {entities}")
    return False


def check_example_sensitive_prompt():
    print("=== Example-sensitive-prompt.txt entities ===")
    text = (
        "Server=production.db.internal;User Id=admin;Password=p@ssw0rd!;"
        "smtp_password=my SMTP password; "
        "AKIAJ4XGLQWI7X5O7Z5Q; "
        "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; "
        "sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; "
        "ssh root@198.51.100.0; "
        "postgres://dbuser:secret123@staging.db.example.com:5432/mydb"
    )
    result = post("/analyze", {"text": text, "language": "en"})
    entity_types = {e["entity_type"] for e in result.get("entities", [])}
    expected = {
        "CONNECTION_STRING",
        "AWS_ACCESS_KEY",
        "GITHUB_TOKEN",
        "OPENAI_API_KEY",
    }
    found = expected & entity_types
    missing = expected - entity_types
    if missing:
        print(f"  PARTIAL — detected {found}, missing: {missing}")
        return False
    print(f"  OK — all expected entities detected: {found}")
    return True


def main():
    checks = [
        check_health,
        check_aws_access_key,
        check_aws_secret_key,
        check_github_token,
        check_openai_key,
        check_private_key,
        check_jwt,
        check_connection_string_url,
        check_connection_string_sqlserver,
        check_connection_string_ssh,
        check_example_sensitive_prompt,
    ]

    passed = 0
    failed = 0
    for check in checks:
        try:
            if check():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"  ERROR: {e}")
            failed += 1

    print(f"\n=== Results: {passed} passed, {failed} failed ===")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()