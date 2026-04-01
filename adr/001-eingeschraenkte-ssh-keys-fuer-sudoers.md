# ADR 001: Eingeschränkte SSH-Keys für sudoers-Installation

**Status:** Vorgeschlagen
**Datum:** 2026-04-01

---

## Kontext

`allow_claude.sh` soll Sudoers-Dateien auf dem Remote-Server installieren. Der aktuelle Ansatz kopiert Dateien per `scp` als unprivilegierter User `master` nach `/tmp`. Das Problem: `sudo` verweigert Sudoers-Dateien, die nicht `root:root` gehören und nicht `chmod 440` haben — was `master` nicht setzen kann.

## Entscheidung

Statt breitem Root-Zugang wird ein separater SSH-Key `~/.ssh/sudoers_admin` eingesetzt, der in `/root/.ssh/authorized_keys` mit einer `command=`-Einschränkung eingetragen ist. Der Key darf ausschließlich ein fest definiertes Skript auf dem Server aufrufen.

### Ablauf `allow_claude.sh`

1. `scp` als `master` kopiert die Permissions-Datei nach `/tmp/$PERM` auf dem Server
2. `ssh -i ~/.ssh/sudoers_admin root@$SERVER install-sudoers.sh $PERM` ruft das eingeschränkte Skript auf

### Skript auf dem Server: `/usr/local/bin/install-sudoers.sh`

```bash
mv /tmp/$1 /etc/sudoers.d/
chown root:root /etc/sudoers.d/$1
chmod 440 /etc/sudoers.d/$1
```

Gehört `root`, `chmod 700`, wird nur über den eingeschränkten Key erreichbar.

### authorized_keys-Eintrag (Beispiel)

```
command="/usr/local/bin/install-sudoers.sh $SSH_ORIGINAL_COMMAND",no-pty,no-port-forwarding ssh-ed25519 AAAA... sudoers_admin
```

### `revoke_claude.sh`

Eigener zweiter eingeschränkter Key (`~/.ssh/sudoers_revoke`) mit `command=`-Eintrag der nur `/usr/local/bin/remove-sudoers.sh` aufrufen darf.

---

## Zu erstellende Dateien

| Datei | Zweck |
|-------|-------|
| `setup.sh` | Einmaliges Setup: Keys generieren, Server-Skripte einrichten, authorized_keys befüllen |
| `allow_claude.sh` | scp + eingeschränkter install-Key |
| `revoke_claude.sh` | ssh + eingeschränkter revoke-Key |
| `tests/grant.bats` | Syntaxtests via `visudo -c -f` direkt; Integrationstests mit `[ -n "$SERVER" ] \|\| skip` |
| `Dockerfile.test` | ubuntu:24.04 mit bats, sudo, openssh-client |
| `docker-compose.yml` | Mountet `~/.ssh`, setzt `SERVER`; Aufruf: `SERVER=x docker compose run --rm tests` |
| `docker-entrypoint.sh` | Kopiert `~/.ssh` → `/tmp/ssh`, setzt chmod 700/600, exportiert `HOME=/tmp` (Fix: falsche Owner im Container) |

---

## Konsequenzen

- **Sicherheit:** Der `sudoers_admin`-Key hat minimalen Blast Radius — er kann nur eine einzige, vordefinierte Operation ausführen
- **Keine dauerhaften Root-Shell-Rechte** für den Claude-Workflow
- **Setup-Aufwand:** `setup.sh` muss einmalig manuell mit Root-Rechten auf dem Server ausgeführt werden
- **Testbarkeit:** Integrationstests brauchen einen echten Server (`$SERVER`) — werden mit `skip` überbrückt wenn nicht gesetzt
