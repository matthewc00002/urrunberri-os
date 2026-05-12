# UrrunBerri OS

> *urrun* (distant) + *berri* (nouveau) en basque

**Développé par Openema SARL · Mathieu Cadi · 2026**

---

## Concept

UrrunBerri OS est un **système d'exploitation thin client Linux** basé sur Debian — alternative moderne à ThinStation.

La machine démarre directement sur **une seule connexion** configurée à l'avance. L'utilisateur voit uniquement le bureau distant — aucun dashboard, aucun login, aucun système d'exploitation visible.

```
Allumer le PC
      ↓
UrrunBerri OS démarre (10 secondes)
      ↓
Connexion automatique au serveur configuré
      ↓
Bureau Windows / Linux s'affiche directement
```

## Différence avec UrrunBerri (MeshCentral)

| | UrrunBerri | UrrunBerri OS |
|---|---|---|
| Usage | IT staff — gestion multi-serveurs | Utilisateur final — un seul serveur |
| Interface | Dashboard complet | Aucune — connexion directe |
| Login | Oui | Non — auto-connexion |
| Comme | MeshCentral | ThinStation |
| Protocoles | RDP + SSH + VNC + Web + Agent | RDP / VNC / SSH (un seul) |

## Protocoles supportés

- **RDP** → xfreerdp (serveurs Windows)
- **VNC** → tigervnc-viewer (bureaux Linux)
- **SSH** → terminal plein écran
- **Web** → Firefox kiosk (intranet, web apps)

## Configuration

Tout se configure dans `/etc/urrunberri-os/config.conf` :

```bash
# Protocole : rdp | vnc | ssh | web
PROTOCOL=rdp

# Serveur cible
HOST=192.168.1.10
PORT=3389
USERNAME=Administrateur

# Langue : fr | en | es | eu
LANG=fr

# Résolution
RESOLUTION=1920x1080
```

## Dépôts

- **UrrunBerri** (MeshCentral) : https://github.com/matthewc00002/urrunberri
- **UrrunBerri OS** (ThinStation) : https://github.com/matthewc00002/urrunberri-os

## Licence

MIT — Openema SARL · 51 rue de l'industrie · 64700 Hendaye
