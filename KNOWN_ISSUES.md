# Known Issues

Documented limitations and false positives discovered through testing.

## Connection String Detection

### EMAIL_ADDRESS false positive on URL-format credentials

**Severity**: Enhancement

**Description**: When connection string URLs contain words that resemble email addresses (e.g., `adminuser@db.example.com`), Presidio's base EMAIL_ADDRESS recognizer fires on the `user@domain` substring, producing additional false-positive entities alongside the correct CONNECTION_STRING detection.

**Example**:
```
postgres://adminuser:MySecretPass@db.example.com:5432/mydb
```

Detected entities:
- `CONNECTION_STRING` (correct)
- `EMAIL_ADDRESS` (false positive — "adminuser@db.example.com" matches email pattern)

**Impact**: Test assertions that expect exactly 1 entity will fail. This is a Presidio base recognizer behavior, not a bug in our custom recognizer.

**Workaround**: The test suite uses `count >= 1` assertions to allow extra detections. When fixing this, consider adding negative lookbehind/lookahead to the email recognizer or changing the URL format to avoid word-like usernames (e.g., `myuser` instead of `adminuser`).

---

### Password-only basic auth URL not detected

**Severity**: Bug

**Description**: Connection string URLs with empty username (e.g., `https://:token@host/path`) are not detected as CONNECTION_STRING.

**Example**:
```
https://:secret_token@registry.example.com/v2/
```

Detected entities: none (CONNECTION_STRING not found)

**Root cause**: The `http_basic_auth_url` pattern in `recognizers.yaml` requires at least one character in the username field:

```yaml
regex: 'https?://[^/:@]+:[^/@]+@[^/\s]+'
#                    ^^^ one-or-more, should be zero-or-more
```

**Fix**: Change `[^/:@]+` to `[^/:@]*` for the username part of the http_basic_auth_url regex.

---

## GitHub Token Detection

### Fine-grained PATs (`github_pat_`) not supported

**Severity**: Enhancement

**Description**: GitHub fine-grained Personal Access Tokens use the `github_pat_` prefix, which is not matched by our current regex:

```yaml
regex: '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,255}'
```

Fine-grained PATs start with `github_pat_` followed by a different format.

**Example**:
```
github_pat_11AAAAAAAAAA0_0123456789abcdefghijklmnopqrst
```

Detected entities: none (correct — not supported)

**Workaround**: Add `github_pat_` as a recognized prefix in `recognizers.yaml`.