.PHONY: up down flutter-shell pub-get gen test web

up:
	supabase start
	docker compose up -d flutter

down:
	docker compose down
	supabase stop

flutter-shell:
	docker compose exec flutter bash

pub-get:
	docker compose exec flutter flutter pub get

gen:
	docker compose exec flutter dart run build_runner build --delete-conflicting-outputs

test:
	docker compose exec flutter flutter test

web:
	docker compose exec flutter flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
