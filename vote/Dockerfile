FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc build-essential && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip wheel --no-cache-dir -r requirements.txt -w /wheels

FROM python:3.11-slim 
WORKDIR /app
RUN addgroup votegroup && adduser --no-create-home --disabled-login --ingroup votegroup voteuser
COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index -r requirements.txt -f /wheels && rm -rf /wheels
COPY . /app 
RUN chown -R voteuser:votegroup /app
USER voteuser
ENV PORT=8080
EXPOSE 8080
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--workers", "2"]
