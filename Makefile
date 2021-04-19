IMG ?= chph/dbench:v1.0.0
BASE_IMG ?= chph/alpine-fio:v1.0.0

all:
	@echo "cannot test in parallel!!!"

.PHONY: image
image:
	docker build -f Dockerfile -t ${IMG} .

.PHONY: push
push: image
	docker push ${IMG}

.PHONY: push-base
push-base: 
	docker pull dmonakhov/alpine-fio
	docker tag dmonakhov/alpine-fio ${BASE_IMG}
	docker push ${BASE_IMG}

.PHONY: longhorn
longhorn: examples/longhorn-test.yaml
	kubectl apply -f $<

.PHONY: openebs-jiva
openebs-jiva: examples/openebs-jiva-test.yaml
	kubectl apply -f $<

.PHONY: openebs-device
openebs-device: examples/openebs-device-test.yaml
	kubectl apply -f $<

.PHONY: openebs-hostpath
openebs-hostpath: examples/openebs-hostpath-test.yaml
	kubectl apply -f $<

.PHONY: openebs-cstor
openebs-cstor: examples/openebs-cstor-test.yaml
	kubectl apply -f $<

.PHONY: warpdrive
warpdrive: examples/warpdrive-test.yaml
	kubectl apply -f $<

.PHONY: topolvm
topolvm: examples/topolvm-test.yaml
	kubectl apply -f $<

.PHONY: hostpath
hostpath: examples/hostpath-test.yaml
	kubectl apply -f $<

.PHONY: local
local: examples/localvolume-test.yaml
	kubectl apply -f $<

.PHONY: log
log:
	@kubectl logs job/dbench -f

.PHONY: get
get:
	@kubectl get po -o wide | grep dbench

.PHONY: watch
watch:
	@kubectl get po -o wide -w | grep dbench

.PHONY: report
report:
	@kubectl logs job/dbench > $(shell date +"%Y%m%d-%H%M%s").txt

.PHONY: clean
clean:
	@kubectl delete -f ./examples 2> /dev/null
