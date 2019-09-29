FROM python:3.7-alpine as base

FROM base as builder

RUN mkdir /install
WORKDIR /install
COPY requirements.txt /tmp/requirements.txt
RUN pip install --install-option="--prefix=/install" -r /tmp/requirements.txt


FROM base
COPY --from=builder /install /usr/local
COPY src /app
WORKDIR /app
CMD ["gunicorn", "-w 4", "main:app"]

