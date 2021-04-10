FROM python:3.9-slim-buster AS builder

# convert pyproject.yaml to requirements.txt
WORKDIR /build
RUN pip install --upgrade pip
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry export --dev --without-hashes -f requirements.txt --output requirements.txt

############################################
FROM python:3.9-slim-buster
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /build

# install nodejs
RUN apt update && apt install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt update && apt install -y nodejs

# install necessary packages
COPY --from=builder /build/requirements.txt .
RUN pip install -r ./requirements.txt

# jupyterlab extension for plotly
RUN jupyter labextension install jupyterlab-plotly @jupyter-widgets/jupyterlab-manager plotlywidget

# set user privileges
RUN useradd user
RUN chown -R user /build
RUN mkdir -p /home/user/project && chown -R user /home

USER user
WORKDIR /home/user/project
ENV HOME /home/user

EXPOSE 8888

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--notebook-dir=/home/user/project"]
