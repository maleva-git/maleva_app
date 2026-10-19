# Gitleaks: secret scanning

The full guide for all 3 Maleva repositories is in **maleva-backend**:
`maleva-backend/docs/tools/gitleaks.md`
(https://github.com/maleva-git/maleva-backend/blob/main/docs/tools/gitleaks.md)

## This repository (maleva_app)

- Config: `.gitleaks.toml`. It allowlists sale order form field names, and Google-shaped keys only in the 3 Firebase config files (public by design; keep them restricted in Google Cloud Console).
- Baseline: `.gitleaks-baseline.json` with 2 old findings (a Razorpay key ID in old commented-out lines, already removed from today's code).
- GitHub check: `.github/workflows/gitleaks.yml` (Gitleaks 8.30.1, pinned).
- Remember: anyone who installs the app can unpack it. A real secret (server password, payment secret key) must never be here.

Scan on your Mac, the same as GitHub:

```bash
gitleaks git --redact --no-banner --config .gitleaks.toml --baseline-path .gitleaks-baseline.json .
```

## Your routine (short version)

The full checklist is in section 0 of the main guide.

**Before every push**
- [ ] `git status`, then add files by name. Check `git diff --cached --name-only`.
- [ ] No passwords or keys, no customer files, no `secrets.yaml`.

**After every push**
- [ ] GitHub → **Actions**: **Gitleaks** is green ✅. Red ❌ → fix it the same day.

**Every day**
- [ ] Check GitHub notifications (🔔) for "Run failed".

**Every Monday**
- [ ] Monday's automatic Gitleaks run (09:00 Malaysia time) is green.

**Every month**
- [ ] Check the allowlist in `.gitleaks.toml` and the Gitleaks version.

**Never**
- ❌ Paste a password anywhere. ❌ Merge while Gitleaks is red. ❌ Allowlist a whole folder.

**This repository:** after you run `flutterfire configure` or change Firebase files, check the new keys are **restricted** in Google Cloud Console. A payment **secret** key (Razorpay) never goes in the app.
