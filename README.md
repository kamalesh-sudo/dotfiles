# Dotfiles

This repository is a small, manifest-controlled mirror of selected human-maintained configuration.

## Ownership

- `shared/` contains configuration used by both desktop environments.
- `caelestia/` contains selected Caelestia/KDE configuration.
- `yahpax/` contains selected Hyprland/Yahpax configuration.
- Each manifest maps one live file to one repository path.

Generated themes, caches, runtime state, application databases, downloaded assets, machine-specific state, and secrets are intentionally excluded.

## Commands

```fish
dotpush caelestia "describe the change"
dotpush yahpax "describe the change"
dotfetch caelestia
dotfetch yahpax
```

The target is required. `dotpush` mirrors local files to the repository and removes a manifest destination when its local source has been deleted. `dotfetch` restores only repository files that exist; it never recreates a missing repository file from Git history and never replaces all of `~/.config`.

Both commands refuse unrelated repository changes. They show their exact plan and require confirmation. Fetch creates a timestamped backup under `~/.config/dotfiles-backups/` before replacing files.

Pushing is intentionally not performed during repository preparation.
