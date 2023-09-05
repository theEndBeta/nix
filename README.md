# Nix/NixOS Configuration Flake(s)

## Running

### NixOS

```
nixos-rebuild switch --flake ".#< hostname >"

# i.e.
nixos-rebuild switch --flake ".#$(uname -n)"
```

### home-manager

```
home-manager switch --flake ".#< user >@< hostname >"

# i.e.
home-manager switch --flake ".#$(id -un)@$(uname -n)"
```
