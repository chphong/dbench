IMG ?= chph/dbench:v1.0.0
BASE_IMG ?= chph/alpine-fio:v1.0.0

.PHONY: image
image:
	docker build . -t ${IMG}

.PHONY: push
push: image
	docker push ${IMG}

.PHONY: push-base
push-base: 
	docker pull dmonakhov/alpine-fio
	docker tag dmonakhov/alpine-fio ${BASE_IMG}
	docker push ${BASE_IMG}
