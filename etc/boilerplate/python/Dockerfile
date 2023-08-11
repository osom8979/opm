FROM python:3.9.17-slim as builder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc

WORKDIR /app
COPY . .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/.wheels -r requirements.txt && \
    python setup.py bdist_wheel && \
    cp dist/*.whl /app/.wheels

# --[[ NEXT STAGE
FROM python:3.9.17-slim

WORKDIR /app
COPY --from=builder /app/.wheels /app/.wheels
RUN pip install --no-cache /app/.wheels/* && \
    rm -rf /app/.wheels && \
    addgroup --gid 1001 --system app && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app
USER app

ENTRYPOINT ["python", "-OO", "-m", "%PROJECT_LOWER%"]
CMD ["server"]
