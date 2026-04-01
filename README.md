# permissions_for_claude

Bash-Skripte die Claude temporären, eingeschränkten SSH-Zugang zum Home-Server geben.

## Funktionsweise

```
Laptop                          Server
  setup.sh  ──SSH als master──▶  git clone + authorized_keys eintragen
  
  ssh -i ~/.ssh/sudoers_allow \
      root@$SERVER TO_WHOAMI  ──▶  activate_rule.sh TO_WHOAMI
                                      └─ installiert /etc/sudoers.d/TO_WHOAMI
```

Der `sudoers_allow`-Key darf auf dem Server ausschließlich `activate_rule.sh` aufrufen — keine Shell, kein Port-Forwarding.

## Installation

```bash
git clone https://github.com/fonzerelly/permissions_for_claude
cd permissions_for_claude
SERVER=<deine-server-ip> sudo ./setup.sh
```

`setup.sh` legt Symlinks für `allow_claude` und `revoke_claude` in `/usr/local/bin` an, sodass beide Befehle anschließend systemweit verfügbar sind.

> **Hinweis:** Das geklonte Verzeichnis darf nicht verschoben oder gelöscht werden, solange die Symlinks aktiv sind. Vor einem Umzug bitte zuerst `sudo ./uninstall.sh` ausführen.

Zum Deinstallieren:

```bash
sudo ./uninstall.sh
```

## Voraussetzung: claude-User auf dem Server anlegen

Einmalig manuell auf dem Server ausführen:

```bash
sudo adduser claude
```

Der `claude`-User ist der User dem die Sudo-Rechte über die Permissions-Dateien gewährt werden.

## Einmaliges Setup

```bash
SERVER=<deine-server-ip> ./setup.sh
```

`setup.sh` liest die Repo-URL automatisch aus `git remote get-url origin`.

Was es tut:
1. Erzeugt `~/.ssh/sudoers_allow` (ed25519) — überschreibt einen vorhandenen Key nie
2. Klont das Repo auf dem Server nach `/usr/local/lib/permissions_for_claude`
3. Trägt den Public Key in `/root/.ssh/authorized_keys` ein mit `command=`-Einschränkung (idempotent)

## Nutzung

```bash
ssh -i ~/.ssh/sudoers_allow root@$SERVER TO_WHOAMI
```

## activate_rule.sh

Nimmt einen oder mehrere Permission-Namen als Argumente entgegen (z.B. `TO_WHOAMI`).

Für jeden Permission-Namen:
1. Prüft ob die Datei unter `permissions/<name>` existiert — gibt sonst eine Fehlermeldung aus und bricht ab
2. Validiert die Datei mit `visudo -c -f` auf korrekte Sudoers-Syntax — bricht bei Fehler ab
3. Kopiert die Datei nach `/etc/sudoers.d/<name>`
4. Setzt `chown root:root` und `chmod 440` — beides zwingende Voraussetzungen damit `sudo` die Datei akzeptiert

## Eigene Permissions erstellen

Neue Permission-Dateien können unter `permissions/` abgelegt werden. Zur Syntax der Sudoers-Datei:
https://heshandharmasena.medium.com/explain-sudoers-file-configuration-in-linux-1fe00f4d6159

## Hinweis für Entwickler: Reset für Integrationstests

Um `setup.sh` sauber von vorne zu testen, müssen beide Seiten zurückgesetzt werden.

**Lokal:**
```bash
rm ~/.ssh/sudoers_allow ~/.ssh/sudoers_allow.pub
rm ~/.ssh/sudoers_revoke ~/.ssh/sudoers_revoke.pub
```

**Auf dem Server:**
```bash
sudo rm -rf /usr/local/lib/permissions_for_claude
sudo sed -i '/sudoers_allow/d' /root/.ssh/authorized_keys
sudo sed -i '/sudoers_revoke/d' /root/.ssh/authorized_keys
sudo rm -f /etc/sudoers.d/TO_*
```

## Tests

```bash
./run-tests.sh
```

Tests laufen in Docker (bats). Kein Server nötig — SSH und git werden gemockt.
