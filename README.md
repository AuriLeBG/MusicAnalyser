# Projet: Architecture multi tier avec JEE : MusicAnalyser

Le but du projet va être de partir d'un 3-Tier classique et de le faire grandir
pour en devenir un projet important !

Essayer de prendre un sujet qui vous intéresse, et qui permet des analyses intéressantes. Trouver une source de données
avec 1M de lignes au minimum. Le gouvernement français met à disposition des datasets
sur [data.gouv.fr](https://www.data.gouv.fr/fr/). L'INSEE expose aussi des
données dans leur [catalogue](https://catalogue-donnees.insee.fr/fr/catalogue/recherche). Le nettoyage de la donnée sera
surement nécessaire.

Vous avez à votre disposition un [docker-compose](../j2e/cours/assets/minijournal/docker-compose.yml).
Celui-ci initialize une base PostgreSQL. Il y a également un Grafana. Un Clickhouse est aussi disponible pour faire de
l'analytics.

Il va falloir penser à la volumétrie de données dès le début. Le chargement de la donnée dans les bases de données doit
être automatique au moment où le `docker-compose` est lancé. Vous pouvez utiliser des scripts bash, python, etc.

L'objectif est de réaliser une application qui va venir exposer notre donnée via une API. Ensuite, vous y connecterez un
front. Le front doit afficher votre application. Par exemple si vous avez choisi un dataset sur les films, vous
effectuez un catalogue de films. Et ensuite il faut un onglet où l'on peut visualiser des analyses sur les films (genre
le plus populaire par année, etc).

Il faudra réaliser un [schéma N-Tier](../j2e/cours/images/business_layer.png) de votre projet. Détaillez la partie
métier de votre Spring avec un diagramme de classes UML.

Le motoring de votre application doit être visible dans Grafana. Il sera réaliser avec opentelemetry. Il faut être
capable de voir les logs par composants, les traces des appels HTTP et les métriques de votre application (une custom
est nécessaire).
On réalisera un endpoint qui fail afin de voir les retries dans les traces.

## Lancer le projet

### Prérequis

- Docker

> Tout est conteneurisé : aucune dépendance locale à installer.

### Démarrage

```bash
cd infrastructure
docker compose up -d
```

Le premier démarrage prend quelques minutes : le data-loader importe automatiquement le dataset CSV dans PostgreSQL et ClickHouse, puis s'éteint. Le backend démarre ensuite avec hot reload.

### Services et URLs

| Service | URL | Identifiants |
|---------|-----|-------------|
| **Frontend** (Flutter web) | http://localhost | — |
| **API** (Spring Boot) | http://localhost:8080 | — |
| **Grafana** (monitoring) | http://localhost:3000 | admin / admin |
| PostgreSQL | localhost:5432 | devUser / devPassword |
| ClickHouse | localhost:8123 | devUser / devPassword |

### Ordre de démarrage automatique

```
postgres + clickhouse + grafana  →  data-loader (one-shot)  →  backend  →  frontend
```

Le data-loader s'éteint après import — c'est normal.

### Compte de test

```
POST http://localhost:8080/api/auth/login
{ "username": "admin", "password": "admin" }
```

Retourne un JWT Bearer token à utiliser pour les routes `/api/favorites/**`.

### Endpoints API disponibles

| Méthode | Route | Auth | Description |
|---------|-------|------|-------------|
| POST | `/api/auth/login` | — | Connexion |
| POST | `/api/auth/register` | — | Inscription |
| GET | `/api/artists` | — | Liste / recherche d'artistes |
| GET | `/api/artists/{id}/songs` | — | Chansons d'un artiste |
| GET | `/api/songs` | — | Catalogue paginé |
| GET | `/api/analytics/views-by-year` | — | Tendances par année |
| GET | `/api/analytics/top-artists` | — | Top artistes |
| GET | `/api/analytics/top-genres` | — | Genres populaires |
| GET | `/api/songs/random-fail` | — | Endpoint qui échoue aléatoirement (démo OTel) |
| GET | `/api/songs/random-fail-retry` | — | Même chose avec retry automatique (3 tentatives) |
| GET | `/api/favorites` | Bearer | Favoris de l'utilisateur |
| POST | `/api/favorites` | Bearer | Ajouter un favori |
| DELETE | `/api/favorites/{songId}` | Bearer | Supprimer un favori |

### Monitoring Grafana

Grafana reçoit automatiquement les traces HTTP, logs et métriques custom du backend via OpenTelemetry (port 4318).
Le dashboard **"MusicAnalyser — Métriques Custom"** est provisionné automatiquement au démarrage.

### Commandes utiles

```bash
# Voir les logs en temps réel
docker compose logs -f backend
docker compose logs -f data-loader   # vérifier l'import des données

# Rebuild après modification du code
docker compose up -d --build backend
docker compose up -d --build frontend

# Statut des containers
docker compose ps

# Reset complet (supprime les données — reimporte au prochain up)
docker compose down -v
```

---

## Rendu

- [ ] schéma n tier
- DATA LAYER
  - [ ] base de données Postgres SQL
  - [X] dataset volumineux (1M+ lignes)
  - [X] script d'import automatique dans la base de données (avec nettoyage si nécessaire)
- BUSINESS LAYER
    - [ ] une API en Java Spring Boot qui requête le tier de donnée.
    - [X] une gestion d'utilisateur (basic) avec Spring Sécurité.
    - [ ] le code métier écrit dans des `@Service`s Spring.
    - [ ] au moins un endpoint pour votre besoin utilisateur (ex: liste des films, recherche par auteur, etc).
    - [ ] un endpoint qui fail aléatoirement pour voir les retries dans les traces (peut être l'endpoint de votre API
    - [ ] modèle de la base lié grâce à Hibernate et Spring Data (DAO + Entities)
      principale).
    - [ ] un endpoint d'analyses qui requête la base de données pour faire des analyses (trend, histogram, etc).
- FRONT LAYER
    - [ ] un front minimaliste pour visualiser la donnée via l'API
    - [ ] un chart d'analyses (trend, histogram, ...)
- MONITORING
  - [X] opentelemetry intégré dans l'application
    - [X] logs par composants
    - [X] traces des appels HTTP
    - [ ] métriques custom (ex: nombre d'utilisateurs, nombre de requêtes par endpoint, etc).
- docker compose
    - [X] base de données Postgres SQL
    - [X] base de données Clickhouse pour l'analytics
    - [X] Grafana + OTEL collector 
