
check_defined = \
	$(strip $(foreach 1,$1, \
	$(call __check_defined,$1,$(strip $(value 2)))))

__check_defined = \
	$(if $(value $1),, \
	$(error Undefined $1$(if $2, ($2))))

prune:
	docker system prune

build:
	$(if $(value cache), \
		docker build            -t ${NAME} ., \
		docker build --no-cache -t ${NAME} .)

deploy-test:
	docker network create ${NAME}-net
	docker run --rm -ti --name ${NAME} --network=${NAME}-net -p ${HOST_PORT}:${SERV_PORT} ${NAME}

deploy:
	docker network create ${NAME}-net
	docker run --rm --name ${NAME} --network=${NAME}-net -p ${HOST_PORT}:${SERV_PORT} ${NAME} &

run: clean
	make deploy

clean:
	make stop

stop:
	docker container stop ${NAME}
	docker network rm ${NAME}-net

decompile:
	docker run --rm -v `pwd`:/samples blacktop/retdec /samples/${NAME}

debug:
	$(if $(value tmux), \
		$(if $(value dbg), \
			docker run -ti --rm --privileged \
				--name ${dbg} \
				--volume `pwd`:/samples \
				--volume ~/Project/PWN/docker/script:/script \
				--security-opt seccomp=unconfined \
				--security-opt apparmor=unconfined \
				--cap-add=SYS_ADMIN \
				--cap-add=SYS_PTRACE \
				--workdir=/samples \
				shangkuei/dbg:${dbg} tmux, \
			docker run -ti --rm --privileged \
				--name pwndbg \
				--volume `pwd`:/samples \
				--volume ~/Project/PWN/docker/script:/script \
				--security-opt seccomp=unconfined \
				--security-opt apparmor=unconfined \
				--cap-add=SYS_ADMIN \
				--cap-add=SYS_PTRACE \
				--workdir=/samples \
				shangkuei/pwndbg:latest tmux), \
		$(if $(value dbg), \
			docker run -ti --rm --privileged \
				--name ${dbg} \
				--volume `pwd`:/samples \
				--volume ~/Project/PWN/docker/script:/script \
				--security-opt seccomp=unconfined \
				--security-opt apparmor=unconfined \
				--cap-add=SYS_ADMIN \
				--cap-add=SYS_PTRACE \
				--workdir=/samples \
				shangkuei/dbg:${dbg} bash, \
			docker run -ti --rm --privileged \
				--name pwndbg \
				--volume `pwd`:/samples \
				--volume ~/Project/PWN/docker/script:/script \
				--security-opt seccomp=unconfined \
				--security-opt apparmor=unconfined \
				--cap-add=SYS_ADMIN \
				--cap-add=SYS_PTRACE \
				--workdir=/samples \
				shangkuei/pwndbg:latest bash))

pwn:
	docker run -ti --rm --privileged \
		--name pwn \
		--network=${NAME}-net \
		--volume `pwd`:/samples \
		--volume ~/Project/PWN/docker/script:/script \
		--security-opt seccomp:unconfined \
		--workdir=/samples \
		shangkuei/pwndbg:latest
