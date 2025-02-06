CERTDIR := srcs/requirements/nginx/certs
SECRETSDIR := srcs/secrets
COMPOSE := docker compose

all: certs
	$(COMPOSE) up --build --remove-orphans

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
	docker secret create db_root_pwd $(SECRETSDIR)/db_root_pwd.txt

clean:
	$(COMPOSE) down
	rm -rf $(CERTDIR)
	docker secret rm db_root_pwd wp_db_user_pwd wp_admin_pwd wp_user_pwd

re: clean all db nginx wp certs secrets
