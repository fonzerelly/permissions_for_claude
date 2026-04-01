# permissions_for_claude

Bash-Skripte die Claude temporären, eingeschränkten SSH-Zugang zum Home-Server geben.

## Funktionsweise

```
Laptop                          Server
  setup.sh  ──SSH als master──▶  git clone + authorized_keys eintragen
  
  ssh -i ~/.ssh/sudoers_admin \
      root@$SERVER TO_WHOAMI  ──▶  allow_claude.sh TO_WHOAMI
                                      └─ installiert /etc/sudoers.d/TO_WHOAMI
```

Der `sudoers_admin`-Key darf auf dem Server ausschließlich `allow_claude.sh` aufrufen — keine Shell, kein Port-Forwarding.

## Einmaliges Setup

```bash
SERVER=<deine-server-ip> ./setup.sh
```

`setup.sh` liest die Repo-URL automatisch aus `git remote get-url origin`.

Was es tut:
1. Erzeugt `~/.ssh/sudoers_admin` (ed25519) — überschreibt einen vorhandenen Key nie
2. Klont das Repo auf dem Server nach `/usr/local/lib/permissions_for_claude`
3. Trägt den Public Key in `/root/.ssh/authorized_keys` ein mit `command=`-Einschränkung (idempotent)

## Nutzung

```bash
ssh -i ~/.ssh/sudoers_admin root@$SERVER TO_WHOAMI
```

## allow_claude.sh

Nimmt einen oder mehrere Permission-Namen als Argumente entgegen (z.B. `TO_WHOAMI`).

Für jeden Permission-Namen:
1. Prüft ob die Datei unter `permissions/<name>` existiert — gibt sonst eine Fehlermeldung aus und bricht ab
2. Validiert die Datei mit `visudo -c -f` auf korrekte Sudoers-Syntax — bricht bei Fehler ab
3. Kopiert die Datei nach `/etc/sudoers.d/<name>`
4. Setzt `chown root:root` und `chmod 440` — beides zwingende Voraussetzungen damit `sudo` die Datei akzeptiert

## Tests

```bash
./run-tests.sh
```

Tests laufen in Docker (bats). Kein Server nötig — SSH und git werden gemockt.
