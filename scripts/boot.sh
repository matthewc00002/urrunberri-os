#!/bin/bash
# =============================================================================
#  UrrunBerri OS — Boot Script
#  Démarre la connexion au serveur configuré
#  Auteur : Mathieu Cadi — Openema SARL
# =============================================================================

CONFIG="/etc/urrunberri-os/config.conf"
DISPLAY="${DISPLAY:-:0}"

# ── LOAD CONFIG ───────────────────────────────────────────────────────────────
if [[ ! -f "$CONFIG" ]]; then
    echo "ERROR: Config not found at $CONFIG"
    exit 1
fi
source "$CONFIG"

# ── TRANSLATIONS ──────────────────────────────────────────────────────────────
declare -A MSG_CONNECTING MSG_WAITING MSG_RECONNECTING MSG_ERROR

MSG_CONNECTING[fr]="Connexion en cours..."
MSG_CONNECTING[en]="Connecting..."
MSG_CONNECTING[es]="Conectando..."
MSG_CONNECTING[eu]="Konektatzen..."

MSG_WAITING[fr]="Connexion à $HOST..."
MSG_WAITING[en]="Connecting to $HOST..."
MSG_WAITING[es]="Conectando a $HOST..."
MSG_WAITING[eu]="$HOST-era konektatzen..."

MSG_RECONNECTING[fr]="Reconnexion dans 5 secondes..."
MSG_RECONNECTING[en]="Reconnecting in 5 seconds..."
MSG_RECONNECTING[es]="Reconectando en 5 segundos..."
MSG_RECONNECTING[eu]="5 segundotan berkonektatzen..."

MSG_ERROR[fr]="Erreur de connexion. Vérifiez la configuration."
MSG_ERROR[en]="Connection error. Check configuration."
MSG_ERROR[es]="Error de conexión. Verifique la configuración."
MSG_ERROR[eu]="Konexio errorea. Konfigurazioa egiaztatu."

LANG="${LANG:-fr}"

log() { echo "[UrrunBerri OS] $*"; }

# ── SPLASH SCREEN ─────────────────────────────────────────────────────────────
show_splash() {
    [[ "$SHOW_SPLASH" != "true" ]] && return
    
    # Show splash using the UI (chromium briefly then close)
    SPLASH_DURATION="${SPLASH_DURATION:-5}"
    
    # Set dark background
    xsetroot -solid "#0d2233" 2>/dev/null || true
    
    # Show splash HTML
    SPLASH_HTML="/opt/urrunberri-os/splash/index.html"
    if [[ -f "$SPLASH_HTML" ]]; then
        chromium --no-sandbox --disable-gpu --app="file://$SPLASH_HTML" \
            --window-size=800,480 --window-position=center 2>/dev/null &
        SPLASH_PID=$!
        sleep "$SPLASH_DURATION"
        kill $SPLASH_PID 2>/dev/null || true
    fi
}

# ── CONNECT RDP ───────────────────────────────────────────────────────────────
connect_rdp() {
    log "${MSG_WAITING[$LANG]}"
    
    local args=(
        "/v:${HOST}:${PORT}"
        "/u:${USERNAME}"
        "/size:${RESOLUTION}"
        "/bpp:${COLOR_DEPTH:-32}"
        "/log-level:ERROR"
        "-grab-keyboard"
    )
    
    [[ -n "$DOMAIN" ]]           && args+=("/d:$DOMAIN")
    [[ -n "$PASSWORD" ]]         && args+=("/p:$PASSWORD")
    [[ "$FULLSCREEN" == "true" ]] && args+=("/f")
    [[ "$RDP_CLIPBOARD" == "true" ]] && args+=("/clipboard")
    [[ "$RDP_FONTS" == "true" ]]  && args+=("/fonts" "/aero")
    [[ "$RDP_SOUND" == "true" ]]  && args+=("/sound")
    [[ "$RDP_RECONNECT" == "true" ]] && args+=("+auto-reconnect" "/auto-reconnect-max-retries:10")

    xfreerdp "${args[@]}"
    return $?
}

# ── CONNECT VNC ───────────────────────────────────────────────────────────────
connect_vnc() {
    log "${MSG_WAITING[$LANG]}"
    local viewer
    viewer=$(which tigervnc-viewer 2>/dev/null || which vncviewer 2>/dev/null)
    
    if [[ -z "$viewer" ]]; then
        log "ERROR: No VNC viewer found. Install: sudo apt install tigervnc-viewer"
        exit 1
    fi
    
    "$viewer" "${HOST}:${PORT}" -FullColor -FullScreen
    return $?
}

# ── CONNECT SSH ───────────────────────────────────────────────────────────────
connect_ssh() {
    log "${MSG_WAITING[$LANG]}"
    # Open SSH in a fullscreen terminal
    local term
    term=$(which xterm 2>/dev/null)
    
    if [[ -z "$term" ]]; then
        log "ERROR: xterm not found"
        exit 1
    fi
    
    xterm -fullscreen -e "ssh ${USERNAME}@${HOST} -p ${PORT}"
    return $?
}

# ── CONNECT WEB ───────────────────────────────────────────────────────────────
connect_web() {
    log "${MSG_WAITING[$LANG]}"
    local url="$HOST"
    [[ "$url" != http* ]] && url="https://${url}"
    
    chromium --no-sandbox --disable-gpu --kiosk "$url"
    return $?
}

# ── MAIN LOOP ─────────────────────────────────────────────────────────────────
main() {
    log "UrrunBerri OS starting..."
    log "Protocol: $PROTOCOL | Host: $HOST:$PORT | User: $USERNAME | Lang: $LANG"
    
    # Show splash screen
    show_splash
    
    # Set dark background while connecting
    xsetroot -solid "#0d2233" 2>/dev/null || true
    
    # Connection loop — auto-reconnect on disconnect
    while true; do
        log "${MSG_CONNECTING[$LANG]}"
        
        case "$PROTOCOL" in
            rdp)  connect_rdp  ;;
            vnc)  connect_vnc  ;;
            ssh)  connect_ssh  ;;
            web)  connect_web  ;;
            *)
                log "ERROR: Unknown protocol '$PROTOCOL'. Use: rdp | vnc | ssh | web"
                exit 1
                ;;
        esac
        
        EXIT_CODE=$?
        
        if [[ "$RDP_RECONNECT" == "true" ]]; then
            log "${MSG_RECONNECTING[$LANG]}"
            xsetroot -solid "#0d2233" 2>/dev/null || true
            sleep 5
        else
            break
        fi
    done
}

main
