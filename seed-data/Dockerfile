FROM python:3.11-slim
WORKDIR /seed
RUN apt-get update && apt-get install -y --no-install-recommends apache2-utils && rm -rf /var/lib/apt/lists/*
RUN addgroup seedgroup && adduser --no-create-home --disabled-login --ingroup seedgroup seeduser
COPY . .
RUN chown -R seeduser:seedgroup /seed
USER seeduser
RUN python make-data.py
ENTRYPOINT ["/bin/sh", "/seed/generate-votes.sh"]
