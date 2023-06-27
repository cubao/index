FROM ghcr.io/cubao/build-env-manylinux2014-x64:v0.0.3
WORKDIR /index
ADD requirements.txt /index/requirements.txt
ADD docs/requirements.txt /index/docs/requirements.txt
RUN python3 -m pip install -r requirements.txt
