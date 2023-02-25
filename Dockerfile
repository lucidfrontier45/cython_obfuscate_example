#----------cython-builder----------#
FROM python:3.11 as cython-builder
WORKDIR /project

RUN pip install -U pip setuptools wheel
RUN pip install "cython>=3.0.0a11"

COPY src /project/src
COPY setup.py /project/setup.py
RUN python setup.py build

RUN mv src raw
RUN mv build/lib.linux-x86_64-cpython-311 cython

#----------builder----------#
FROM python:3.11 as builder
WORKDIR /project
RUN pip install -U pip setuptools wheel
RUN pip install pdm

# first install dependencies to cache them
COPY pyproject.toml pdm.lock /project/
RUN pdm sync --prod --no-self

# cython: use cython to obfuscate code
# raw: no obfuscation
ARG BUILD_TYPE="cython"

COPY --from=cython-builder /project/${BUILD_TYPE} /project/src
# root __init__.py needs to be a text file for PDM to read it
COPY --from=cython-builder /project/raw/app/__init__.py /project/src/app/__init__.py
# now install the project
RUN pdm sync --prod --no-editable

#----------runner----------#
FROM python:3.11-slim as runner
WORKDIR /project

COPY --from=builder /project/.venv /project/.venv
ENV PATH /project/.venv/bin:$PATH

COPY main.py /project/main.py

CMD ["python", "main.py"]