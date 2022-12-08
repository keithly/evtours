# Define custom function directory
ARG FUNCTION_DIR="/src"

FROM public.ecr.aws/docker/library/python:3.11.1-slim-bullseye as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Install aws-lambda-cpp build dependencies and curl
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

RUN curl https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie -o /usr/local/bin/aws-lambda-rie && \
    chmod +x /usr/local/bin/aws-lambda-rie

RUN mkdir -p ${FUNCTION_DIR} && \
    python3 -m pip install -U --no-cache-dir pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --target ${FUNCTION_DIR} awslambdaric boto3

COPY src ${FUNCTION_DIR}

FROM public.ecr.aws/docker/library/python:3.11.1-slim-bullseye

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

COPY --from=build-image /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY ./lambda-entrypoint.sh /lambda-entrypoint.sh

ENTRYPOINT [ "/lambda-entrypoint.sh", "evtours/blah.handler" ]
