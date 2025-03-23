CERTDIR := srcs/requirements/nginx/certs
SECRETSDIR := srcs/secrets
COMPOSE := docker compose

all: swarm_init certs
	mkdir -p /home/lzipp/data/web
	mkdir -p /home/lzipp/data/db
	$(COMPOSE) up --remove-orphans --build

build:
	$(COMPOSE) build --no-cache

swarm_init:
	@if ! docker secret ls > /dev/null 2>&1; then \
		echo "Initializing Docker Swarm..."; \
		docker swarm init; \
	else \
		echo "Docker Swarm is already initialized."; \
	fi

stop:
	$(COMPOSE) down

db:
	$(COMPOSE) up --build db

nginx: certs
	$(COMPOSE) up --build nginx

wp:
	$(COMPOSE) up --build wordpress

certs:
	if [ ! -d $(CERTDIR) ]; then \
		mkdir -p $(CERTDIR); \
		openssl req -x509 -newkey rsa:4096 -keyout $(CERTDIR)/key.pem -out $(CERTDIR)/cert.pem \
			-sha256 -days 3650 -nodes -subj "/C=DE/ST=BadenWuerttemberg/L=Heilbronn/O=42Heilbronn/OU=Student/CN=localhost"; \
		openssl dhparam -out $(CERTDIR)/dhparam.pem 2048; \
	fi

secrets:
	docker secret create wp_db_user_pwd $(SECRETSDIR)/wp_db_user_pwd.txt
	docker secret create wp_admin_pwd $(SECRETSDIR)/wp_admin_pwd.txt
	docker secret create wp_user_pwd $(SECRETSDIR)/wp_user_pwd.txt
	docker secret create db_root_pwd $(SECRETSDIR)/wp_db_root_pwd.txt

clean:
# sudo docker exec -it db /bin/bash -c "rm -rf /var/lib/mysql/already_initialized"
	$(COMPOSE) down
	docker volume rm inception_web_data inception_db_data
	docker secret rm wp_db_root_pwd wp_db_user_pwd wp_admin_pwd wp_user_pwd

re: clean all db nginx wp certs secrets
