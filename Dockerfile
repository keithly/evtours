# based on
# https://github.com/aws/aws-lambda-python-runtime-interface-client/blob/970e9c1d2613e0ce9c388547c76ac30992ad0e96/README.md
ARG FUNCTION_DIR="/src"

FROM public.ecr.aws/docker/library/python:3.11.1-slim-bullseye as build-image

ARG FUNCTION_DIR

# Install aws-lambda-cpp build dependencies (for awslambdaric) and curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ \
    make \
    cmake \
    unzip \
    libcurl4-openssl-dev \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie -Lo /usr/local/bin/aws-lambda-rie && \
    chmod +x /usr/local/bin/aws-lambda-rie

RUN mkdir -p ${FUNCTION_DIR} && \
    python3 -m pip install -U --no-cache-dir pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --target ${FUNCTION_DIR} awslambdaric boto3

COPY src ${FUNCTION_DIR}

FROM public.ecr.aws/docker/library/python:3.11.1-slim-bullseye

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir --target ${FUNCTION_DIR} -r requirements.txt

COPY --from=build-image /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY ./lambda-entrypoint.sh /lambda-entrypoint.sh

ENV APP_VERSION=0.1.0

ENTRYPOINT [ "/lambda-entrypoint.sh", "evtours/function_url.handler" ]
