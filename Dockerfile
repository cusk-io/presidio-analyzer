ARG BASE_VERSION=latest
FROM mcr.microsoft.com/presidio-analyzer:${BASE_VERSION}

USER root

COPY recognizers.yaml /app/recognizers.yaml

# Merge base recognizers with our custom secrets recognizers.
# Output is baked into the image — no runtime permission issues.
RUN python3 <<'PYEOF'
import yaml

with open('/app/presidio_analyzer/conf/default_recognizers.yaml') as f:
    data = yaml.safe_load(f)

with open('/app/recognizers.yaml') as f:
    custom_data = yaml.safe_load(f)

base_recognizers = data.get('recognizers', [])
base_names = {r['name'] for r in base_recognizers}

custom_recognizers = custom_data.get('custom_recognizers', [])
added = skipped = 0

for rec in custom_recognizers:
    name = rec.get('name')
    if name in base_names:
        print(f"Skipping '{name}' — already in base image")
        skipped += 1
    else:
        base_recognizers.append(rec)
        print(f"Added '{name}'")
        added += 1

data['recognizers'] = base_recognizers

with open('/app/custom_recognizers.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False, sort_keys=False)

print(f"Done: {added} added, {skipped} skipped, {len(base_recognizers)} total")
PYEOF

ENV RECOGNIZER_REGISTRY_CONF_FILE=/app/custom_recognizers.yaml
ENV GUNICORN_CMD_ARGS="--no-control-socket"

# Make the merged config readable by UID 1000 at runtime
RUN chmod 644 /app/custom_recognizers.yaml

USER 1000

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=5s --retries=3 --start-period=30s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:3000/health')"