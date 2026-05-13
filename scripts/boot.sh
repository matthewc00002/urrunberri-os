#!/bin/bash
# =============================================================================
#  UrrunBerri OS — Boot Script
#  Login dialog with IP, Port, Username, Password
#  Author : Mathieu Cadi — Openema SARL
# =============================================================================

CONFIG="/etc/urrunberri-os/config.conf"
[[ -f "$CONFIG" ]] && source "$CONFIG"

RESOLUTION="${RESOLUTION:-1920x1080}"
DISPLAY="${DISPLAY:-:0}"

xhost + >/dev/null 2>&1 || true
xsetroot -solid "#0d2233" 2>/dev/null || true

show_login() {
    RESULT=$(DISPLAY=$DISPLAY zenity --forms \
        --title="UrrunBerri OS" \
        --text="Connexion RDP" \
        --add-entry="IP" \
        --add-entry="Port" \
        --add-entry="Utilisateur" \
        --add-password="Mot de passe" \
        --ok-label="Connexion" \
        --width=360 2>/dev/null)
    [[ $? -ne 0 ]] && return 1
    CONN_HOST=$(echo "$RESULT" | cut -d'|' -f1)
    CONN_PORT=$(echo "$RESULT" | cut -d'|' -f2)
    USERNAME=$(echo "$RESULT" | cut -d'|' -f3)
    PASSWORD=$(echo "$RESULT" | cut -d'|' -f4)
    [[ -z "$CONN_HOST" ]] && return 1
    [[ -z "$CONN_PORT" ]] && CONN_PORT=3389
    return 0
}

while true; do
    xsetroot -solid "#0d2233" 2>/dev/null || true
    if ! show_login; then sleep 2; continue; fi
    echo "[UrrunBerri OS] Connexion a ${CONN_HOST}:${CONN_PORT} en tant que ${USERNAME}..."
    DISPLAY=$DISPLAY xfreerdp /v:${CONN_HOST}:${CONN_PORT} /u:${USERNAME} /p:${PASSWORD} \
        /size:${RESOLUTION} /cert:ignore /clipboard /fonts /log-level:ERROR
    echo "[UrrunBerri OS] Deconnecte. Retour a l'ecran de connexion..."
    sleep 3
done
