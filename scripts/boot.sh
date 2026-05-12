#!/bin/bash
# =============================================================================
#  UrrunBerri OS — Boot Script
#  Connects directly to the configured server — loops forever until login
#  Author : Mathieu Cadi — Openema SARL
# =============================================================================

CONFIG="/etc/urrunberri-os/config.conf"
[[ -f "$CONFIG" ]] && source "$CONFIG"

# Defaults
PROTOCOL="${PROTOCOL:-rdp}"
HOST="${HOST:-192.168.1.10}"
PORT="${PORT:-3389}"
USERNAME="${USERNAME:-Administrateur}"
PASSWORD="${PASSWORD:-}"
DOMAIN="${DOMAIN:-}"
RESOLUTION="${RESOLUTION:-1920x1080}"
LANG="${LANG:-fr}"
RDP_RECONNECT="${RDP_RECONNECT:-true}"

# Messages
declare -A MSG
MSG[fr]="Connexion en cours..."
MSG[en]="Connecting..."
MSG[es]="Conectando..."
MSG[eu]="Konektatzen..."

log() { echo "[UrrunBerri OS] $*"; }

# Allow display access
DISPLAY="${DISPLAY:-:0}"
xhost + >/dev/null 2>&1 || true

log "${MSG[$LANG]:-Connecting...}"
log "Protocole: $PROTOCOL | Serveur: $HOST:$PORT | Utilisateur: $USERNAME"

# Set dark background
xsetroot -solid "#0d2233" 2>/dev/null || true

# ── MAIN LOOP — retries forever ───────────────────────────────────────────────
while true; do
    case "$PROTOCOL" in
        rdp)
            ARGS=(
                "/v:${HOST}:${PORT}"
                "/u:${USERNAME}"
                "/size:${RESOLUTION}"
                "/cert:ignore"
                "/clipboard"
                "/fonts"
                "/log-level:ERROR"
            )
            [[ -n "$PASSWORD" ]] && ARGS+=("/p:${PASSWORD}")
            [[ -n "$DOMAIN" ]]   && ARGS+=("/d:${DOMAIN}")

            DISPLAY=$DISPLAY xfreerdp "${ARGS[@]}"
            ;;

        vnc)
            DISPLAY=$DISPLAY vncviewer "${HOST}:${PORT}" 2>/dev/null
            ;;

        ssh)
            DISPLAY=$DISPLAY xterm -fullscreen -e "ssh ${USERNAME}@${HOST} -p ${PORT}" 2>/dev/null
            ;;

        web)
            URL="$HOST"
            [[ "$URL" != http* ]] && URL="https://${URL}"
            DISPLAY=$DISPLAY firefox --kiosk "$URL" 2>/dev/null
            ;;
    esac

    # After disconnect — show dark background and retry
    xsetroot -solid "#0d2233" 2>/dev/null || true
    log "Déconnecté. Reconnexion dans 5 secondes..."
    sleep 5
done
