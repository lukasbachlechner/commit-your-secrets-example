# Commit your secrets (at least in dev)

A ~50 line example of the workflow from the talk: dev secrets live **encrypted,
in git**, and `pnpm dev` just works. Two tools, no server, no account.

```bash
brew install sops age
git clone <this repo> && cd commit-your-secrets-example
pnpm dev
```

```
hello from an encrypted file
STRIPE_SECRET_KEY: sk_test_…
DATABASE_URL: postgres…
```

Those values came out of [`secrets/dev.yaml`](secrets/dev.yaml) — go read it,
it's committed. (This repo ships its own age key so the clone-and-run above
works; see [`keys/README.md`](keys/README.md) for why that's a demo-only thing.)

## Every command is a pnpm script

| Command | What it does |
| --- | --- |
| `pnpm keygen` | Makes your age keypair in `~/.config/sops/age/keys.txt` and prints the public half |
| `pnpm dev` | Runs the app with the decrypted values in its environment |
| `pnpm secrets` | Opens `secrets/dev.yaml` in your editor, as plaintext |
| `pnpm grant` | Rewraps the file for whoever is listed in `.sops.yaml` |

## What's in here

| File | Why |
| --- | --- |
| `secrets/dev.yaml` | The secrets. Encrypted values, plaintext keys, committed. |
| `.sops.yaml` | Who may decrypt. Changing it is a pull request. |
| `scripts/with-env.sh` | Decrypts into the environment and execs your command. |
| `package.json` | The one line that changed: `"dev": "./scripts/with-env.sh node app.mjs"`. |
| `app.mjs` | Stands in for your app. Validates the env with zod, then prints what it got. |

## The three moves

**01 — Edit a secret**

```bash
pnpm secrets
```

Your editor opens on plaintext. Save, and `git diff` shows one changed line of
ciphertext.

**02 — Run the app**

```bash
pnpm dev
```

The wrapper finds `secrets/dev.yaml`, decrypts it in memory with your age key,
and execs `node app.mjs` with the values in its environment. Nothing hits disk.
No `secrets/dev.yaml`? It falls back to a plaintext `.env`, so a team can
migrate one repo at a time. No key? It tells you where to put one.

**03 — Give someone access**

They run `pnpm keygen` and send you the public key it prints (it's public — the
team channel is fine). You paste it into `.sops.yaml`, then:

```bash
pnpm grant
git commit -am "give priya access to dev secrets"
```

The encrypted values aren't touched — only the per-recipient wrapped copy of the
data key in the file header. That's why onboarding is a small, reviewable diff.

## What this doesn't fix

- **Removal is not revocation.** Anyone who had a value still has it. Rotate it.
- **Granularity is the file.** Split by environment or scope.
- **Dev secrets only.** Production stays in your vault.
- **Lose the key, lose access.** Two recipients minimum, back up the keyfile.
- **Ciphertext is forever.** Assume a future break; rotate on a schedule.

## Forgot a key?

`app.mjs` parses `process.env` with a zod schema before it does anything, so a
missing or malformed value fails loudly at startup instead of halfway through a
request:

```
Bad or missing secrets. Run `pnpm secrets` and fix secrets/dev.yaml:

  STRIPE_SECRET_KEY: must be a Stripe *test* key
```

That schema replaces `.env.example` — it's the same contract about shape, except
it's executable and it can't drift.
