FROM python:3.9-slim-buster
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# install neccessary packages
RUN apt-get update && apt-get install -y curl

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

# install python packages
WORKDIR /project
RUN pip install --upgrade pip
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false && poetry install

# jupyterlab extension for plotly
RUN poetry run jupyter labextension install jupyterlab-plotly @jupyter-widgets/jupyterlab-manager plotlywidget

# set user privileges
RUN useradd user && chown -R user /project
USER user
ENV HOME /project

EXPOSE 8888

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["poetry", "run", "jupyter", "lab", "--ip=0.0.0.0"]
