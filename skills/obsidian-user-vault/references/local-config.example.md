# local-config.example.md

Copy to `local-config.md` (same folder) and fill for **this machine**.  
Agents: prefer `local-config.md` over guessing.  
Public git: commit the example; optionally gitignore `local-config.md` if paths/ids are private.

```markdown
# local-config (this host)

## Vault
- OBSIDIAN_VAULT_PATH: /absolute/path/to/vault
- Remote Sync name (optional): MyVault
- Remote vault id (optional):
- Sync host region (optional):

## Headless CLI (`ob`)
- OBSIDIAN_OB_HOME: /home/youruser
  (config lives in $OBSIDIAN_OB_HOME/.config/obsidian-headless/)
- OBSIDIAN_OB_PATH: /home/youruser/.npm-global/bin
  (directory that contains the `ob` binary)
- OBSIDIAN_SYNC_LOG: /home/youruser/logs/obsidian-sync.log
- OBSIDIAN_SYNC_PID: /home/youruser/logs/obsidian-sync.pid
- Watchdog / process manager notes (optional):

## Agent identity
- OBSIDIAN_AGENT_NAME: YourAgentNick

## Notes
- Desktop Obsidian Sync must not run on this same device while headless continuous is active.
- File tools need the absolute vault path, not $OBSIDIAN_VAULT_PATH literally.
```

### Minimal env-only setup (no local-config file)

```bash
export OBSIDIAN_VAULT_PATH="/absolute/path/to/vault"
export OBSIDIAN_OB_HOME="$HOME"
export OBSIDIAN_OB_PATH="$HOME/.npm-global/bin"   # if needed
export OBSIDIAN_SYNC_LOG="/tmp/obsidian-sync.log"
export OBSIDIAN_AGENT_NAME="MyAgent"
export PATH="$OBSIDIAN_OB_PATH:$PATH"
export HOME="$OBSIDIAN_OB_HOME"   # when invoking ob
```
