FROM python:3.7-alpine AS root

FROM root AS builder

WORKDIR /install

COPY requirements.txt .

RUN apk add --no-cache gcc musl-dev linux-headers
RUN pip install --install-option="--prefix=/install" -r requirements.txt

FROM root
COPY --from=builder /install /usr/local
COPY /blog .

ENV FLASK_APP app.py
ENV FLASK_RUN_HOST 0.0.0.0

CMD ["flask", "run"]