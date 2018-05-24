.PHONY: build

default: build

build:
	docker build -t lanmaoly/svn-server .

