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

COPY pyproject.toml pdm.lock /project/
RUN pdm sync --prod --no-self

COPY --from=cython-builder /project/cython /project/src
# root __init__.py needs to be a text file for PDM to read it
COPY --from=cython-builder /project/raw/app/__init__.py /project/src/app/__init__.py
RUN pdm sync --prod --no-editable

#----------runner----------#
FROM python:3.11-slim as runner
WORKDIR /project

COPY --from=builder /project/.venv /project/.venv
ENV PATH /project/.venv/bin:$PATH

COPY main.py /project/main.py

CMD ["python", "main.py"]