FROM python:3.12-slim

RUN pip install --no-cache-dir mlflow psycopg2-binary && \
    mkdir -p /mlartifacts && \
    chmod 777 /mlartifacts

EXPOSE 5000

CMD ["mlflow", "server"]
