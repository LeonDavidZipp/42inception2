CERTDIR := srcs/requirements/nginx/certs
SECRETSDIR := secrets
COMPOSE := docker compose

all: start

start: get_env swarm_init certs
	mkdir -p /home/lzipp/data/web
	mkdir -p /home/lzipp/data/db
	$(COMPOSE) up --remove-orphans --build

get_env:
	@if [ ! -f .env ]; then \
		cp ../.env .env; \
	fi
	@if [ ! -d secrets ]; then \
		cp -r ../secrets secrets; \
	fi

swarm_init:
	@if ! docker secret ls > /dev/null 2>&1; then \
		echo "Initializing Docker Swarm..."; \
		docker swarm init; \
	else \
		echo "Docker Swarm is already initialized."; \
	fi

stop:
	$(COMPOSE) down

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
	docker secret create wp_db_root_pwd $(SECRETSDIR)/wp_db_root_pwd.txt

clean:
	$(COMPOSE) down
	rm -rf /home/lzipp/data/web /home/lzipp/data/db
	docker volume rm test_db_data test_web_data
	docker secret rm wp_db_root_pwd wp_db_user_pwd wp_admin_pwd wp_user_pwd

re: clean all db nginx wp certs secrets
