# This private key is published on purpose

`demo-key.txt` is the age private key that decrypts `secrets/dev.yaml`. It is
committed so that cloning this repo and running `npm run dev` works with no
setup at all.

In a real repo it never gets committed. Each person generates their own:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

...and the *public* half goes into `.sops.yaml` via a pull request.

The "secrets" in this repo are Stripe's public test-key example and a fake
local database URL. Nothing here protects anything.
