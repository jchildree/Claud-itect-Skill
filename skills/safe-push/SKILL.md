---
name: safe-push
description: Use when about to push to any git remote -- runs large-file, test, uncommitted-change, and diverged-history checks before pushing
disable-model-invocation: true
---

# Safe Push

Run these checks in order before pushing to any remote. Stop and report if any check fails; never push until the user resolves a blocking issue.

## 1. Large-file check

**Windows (PowerShell):**
```powershell
git ls-files | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue } |
  Where-Object { $_.Length -gt 52428800 } |
  Select-Object FullName, @{Name='MB';Expression={[math]::Round($_.Length/1MB,1)}} |
  Format-Table
```

**Unix (bash):**
```bash
git ls-files | xargs -I{} du -b {} 2>/dev/null | awk '$1 > 52428800 {print $2, int($1/1048576)"MB"}' | sort -rn
```

If any tracked file exceeds 50 MB: **STOP**. Report the filenames and sizes. Do not push until the user resolves the issue (add to `.gitignore`, use Git LFS, or remove from history).

## 2. Test suite check

Check `package.json` (or `Makefile`, `pyproject.toml`, etc.) for a test command. Run it. If tests fail: **STOP** and report. Do not push until tests pass. If no test command exists, note that and continue.

## 3. Uncommitted-changes check

```
git status --short
```

If modified or untracked files exist that the user likely intended to include (i.e., they touch the same areas as recent commits), ask before proceeding.

## 4. Diverged-history check

```
git fetch --dry-run 2>&1
git status -b
```

If the branch has diverged from the remote (shows "have X and Y different"): ask the user explicitly:

> "The branch has diverged from remote. Force-push? (yes/no)"

If the answer is not an explicit "yes": **STOP immediately**. Never force-push without explicit confirmation.

## 5. Push

```
git push
```

If the repo has a GitHub remote, report the PR URL:
```
gh pr view --web 2>/dev/null || gh pr create --draft
```

## On success

Report: branch pushed, commits ahead count, PR URL if available.
