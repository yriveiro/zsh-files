# ZSH files

Modular Zsh configuration with tracked shared defaults and optional local overrides.

## Layout

- `zshrc` is the entrypoint and is intended to be symlinked to `~/.zshrc`.
- `config.d/*.zsh` contains shared config fragments loaded in lexical order.
- `config.local.d/*.zsh` is reserved for machine-local overrides and optional profiling.
- `completions/` contains repo-local completion functions added to `fpath` before completion init.

## Load order

Startup is intentionally thin:

1. `zshrc` enables `extended_glob` and resolves the repo root.
2. `zshrc` loads zinit only if it is already installed.
3. `config.d/*.zsh` is sourced in order.
4. `config.local.d/*.zsh` is sourced in order.
5. `zle_highlight=('paste:none')` is applied.

Important numbered fragments:

- `00_*` shared colors, functions, and platform environment.
- `03_env.zsh` contains common environment settings and shared tool initialization.
- `04_completions.zsh` adds custom completions to `fpath`.
- `05_zinit.zsh` is the single completion-init path when zinit is available.
- `25_completion.zsh` contains completion styles and behavior.

## Install expectations

`install.sh` clones this repo to `${HOME}/.config/zsh` and symlinks `zshrc` to `${HOME}/.zshrc`.

```sh
curl --proto '=https' --tlsv1.2 -LsSf https://raw.githubusercontent.com/yriveiro/zsh-files/main/install.sh | bash
```

Warm up caches and compiled artifacts intentionally after changes:

```sh
./install.sh warmup
```

Shell startup does not install zinit, clone repositories, or perform other network bootstrapping. If zinit is missing, startup prints a concise warning to stderr and continues without plugin loading.

If you want the plugin-managed workflow, install zinit separately before opening a new shell.

## Local overrides

Tracked shared config should stay portable. Machine-specific values belong in `config.local.d`.

Create a machine-local file such as `config.local.d/10_machine.zsh`:

```zsh
export DEV_ROOT="/data/Development"
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
export OLLAMA_API_BASE="https://ollama.example.internal"
export OPENCODE_EXPERIMENTAL=true
```

Only files matching `config.local.d/*.zsh` are sourced at startup. Local override files are intentionally untracked.

## Validation

Run the tracked validation entrypoint after changes:

```sh
./install.sh validate
```

The validation mode runs compact repo-local checks for:

- `bash -n install.sh`
- `zsh -n zshrc config.d/*.zsh`
- no zinit bootstrap in `zshrc`
- local overrides restricted to `config.local.d/*.zsh`
- no `${0:A:h}`, `bashcompinit`, or hardcoded `/Users/...` and `/home/...` paths in `config.d`
- no tracked references to removed helper validation scripts

The validator assumes `bash`, `zsh`, and `grep` are available locally.

## Pre-commit

Install the versioned git hooks when you want local checks before each commit:

```sh
pre-commit install
```

Run the full hook set on demand:

```sh
pre-commit run --all-files
```

The tracked `.pre-commit-config.yaml` currently runs:

- basic repository hygiene checks from `pre-commit-hooks`
- `gitleaks` secret scanning with redacted output

`pre-commit` itself is not installed by shell startup or `install.sh`; install it separately if you want the local hook workflow.

## Warmup

Run the tracked warmup entrypoint when you want startup speed without reintroducing startup-time writes:

```sh
./install.sh warmup
```

Warmup does three things in order:

- runs `./install.sh validate`
- prepares completion and history state directories under `XDG_CACHE_HOME` and `XDG_STATE_HOME`
- starts one interactive shell to warm plugin-managed completion state, explicitly generates the zsh completion dump under `XDG_CACHE_HOME`, then `zcompile`s `zshrc` and `config.d/*.zsh`

Normal shell startup remains read-only apart from the existing history/completion behavior already configured in zsh itself.
