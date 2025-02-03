CERTDIR := src/requirements/nginx/certs
SECRETSDIR := src/secrets

all: certs secrets
	docker-compose up --build --remove-orphans

db:
	docker-compose up --build db

nginx:
	docker-compose up --build nginx

wp:
	docker-compose up --build wordpress

certs:
	mkdir -p $(CERTDIR)
	openssl req -x509 -newkey rsa:4096 -keyout $(CERTDIR)/key.pem -out $(CERTDIR)/cert.pem \
	-sha256 -days 3650 -nodes -subj "/C=DE/ST=BadenWuerttemberg/L=Heilbronn/O=42Heilbronn/OU=Student/CN=localhost"
	openssl dhparam -out $(CERTDIR)/dhparam.pem 2048

secrets:
	docker secret create wp_db_user_pwd $(SECRETSDIR)/wp_db_user_pwd.txt
	docker secret create wp_admin_pwd $(SECRETSDIR)/wp_admin_pwd.txt
	docker secret create wp_user_pwd $(SECRETSDIR)/wp_user_pwd.txt
	docker secret create db_root_pwd $(SECRETSDIR)/db_root_pwd.txt

clean:
	docker-compose down
	rm -rf $(CERTDIR)
	docker secret rm db_root_pwd wp_db_user_pwd wp_admin_pwd wp_user_pwd

re: clean all db nginx wp certs secrets
