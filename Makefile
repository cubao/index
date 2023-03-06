clean:
	rm -rf build dist site
force_clean:
	docker run --rm -v `pwd`:`pwd` -w `pwd` -it alpine/make make clean
.PHONY: clean force_clean

lint:
	pre-commit run -a
lint_install:
	pre-commit install

docs_build:
	mkdocs build
docs_serve:
	mkdocs serve -a 0.0.0.0:8088

jupyterlab:
	jupyter lab --ip=0.0.0.0 --port 8899 --LabApp.token='' --no-browser
