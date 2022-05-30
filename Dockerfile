FROM python:3.10-buster

## PACKAGE MANAGER
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y wget

## CREATE jupyrunner USER
RUN useradd -ms /bin/bash jupyrunner
USER jupyrunner

# conda env
WORKDIR /tmp

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh || exit 1
RUN /bin/bash ~/miniconda.sh -b -p /home/jupyrunner/.miniconda3 || exit 1
RUN rm ~/miniconda.sh && /home/jupyrunner/.miniconda3/bin/conda init bash || exit 1

ENV PATH=/opt/conda/bin:$PATH
ENV PATH=/home/jupyrunner/.miniconda3/bin:$PATH

ARG pythonv=3.10

## CREATE CONDA ENV
RUN /home/jupyrunner/.miniconda3/bin/conda create --name py-${pythonv} python==${pythonv}

ADD --chown=jupyrunner:jupyrunner requirements.txt /tmp/requirements.txt
RUN /home/jupyrunner/.miniconda3/envs/py-${pythonv}/bin/pip install -r /tmp/requirements.txt

## JUPYTER
RUN /home/jupyrunner/.miniconda3/bin/conda install -c conda-forge jupyterlab
RUN /home/jupyrunner/.miniconda3/envs/py-${pythonv}/bin/pip install ipykernel
RUN /home/jupyrunner/.miniconda3/envs/py-${pythonv}/bin/python -m ipykernel install --user --name=py-${pythonv}

# copy notebook config and user settings
ADD --chown=jupyrunner:jupyrunner settings/jupyter_notebook_config.json \
    /home/jupyrunner/.jupyter/jupyter_notebook_config.json
ADD --chown=jupyrunner:jupyrunner settings/tracker.jupyterlab-settings \
    /home/jupyrunner/.jupyter/lab/user-settings/\@jupyterlab/notebook-extension/tracker.jupyterlab-settings

# cleaning and finalizing
RUN  mkdir /home/jupyrunner/project

WORKDIR  /home/jupyrunner/project
EXPOSE 8888

ENTRYPOINT [ "jupyter", "lab", "--notebook-dir","/home/jupyrunner/project/notebooks", "--ip", "0.0.0.0", "--no-browser"]
