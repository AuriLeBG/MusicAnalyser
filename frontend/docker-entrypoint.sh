#!/bin/bash
# =============================================================================
# docker-entrypoint.sh — Watcher Flutter pour le hot reload en Docker
# Surveille lib/ avec inotifywait et redémarre Flutter à chaque modification
# =============================================================================

set -e

echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Fonction pour démarrer Flutter en arrière-plan
start_flutter() {
  echo "🚀 Démarrage de Flutter web..."
  flutter run -d web-server --web-port=80 --web-hostname=0.0.0.0 &
  FLUTTER_PID=$!
  echo "   Flutter PID: $FLUTTER_PID"
}

# Fonction pour arrêter Flutter proprement
stop_flutter() {
  if [ -n "$FLUTTER_PID" ] && kill -0 "$FLUTTER_PID" 2>/dev/null; then
    echo "🛑 Arrêt de Flutter (PID: $FLUTTER_PID)..."
    kill "$FLUTTER_PID" 2>/dev/null
    wait "$FLUTTER_PID" 2>/dev/null || true
  fi
}

# Démarrage initial
start_flutter

echo "👁️  Surveillance de lib/ et pubspec.yaml pour les changements..."
echo "   (Chaque modification déclenchera un redémarrage de Flutter ~30s)"

# Boucle de surveillance
while true; do
  # Attendre un événement de modification de fichier
  inotifywait -r -e close_write,create,delete,move \
    --include '.*\.(dart|yaml|json)$' \
    lib/ pubspec.yaml 2>/dev/null

  echo ""
  echo "🔄 Changement détecté ! Redémarrage de Flutter..."
  stop_flutter
  sleep 1
  start_flutter
done
