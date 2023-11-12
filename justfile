is_nixos := path_exists("/etc/NIXOS")
user := `id -un`
hostname := `uname -n`
home-manager-id := user + "@" + hostname
cmd := if is_nixos == "true" { "nixos-rebuild" } else { "home-manager" }
sudo := if is_nixos == "true" { "sudo" } else { "" }
target := if is_nixos == "true" { hostname } else { home-manager-id }
export NIX_BUILD_CORES := `nproc=$(nproc); echo $(( nproc / 2 ))`

default: sys-info

sys-info:
  @echo "is_nixos:    {{ is_nixos }}"
  @echo "os_family:   {{ os_family() }}"
  @echo "os:          {{ os() }}"
  @echo "arch:        {{ arch() }}"
  @echo "user:        {{ user }}"
  @echo "hostname:    {{ hostname }}"
  @echo "build-cores" {{ NIX_BUILD_CORES }}

[linux]
switch:
  {{sudo}} {{ cmd }} switch --flake ".#{{ target }}"

[linux]
build:
  {{sudo}} {{ cmd }} build --flake ".#{{ target }}"

update:
  nix flake update

[linux]
check:
  nix flake check

[no-cd]
pkg-build dir=".":
  nix-build -E 'with import <nixpkgs> {}; callPackage {{ dir }}/default.nix {}'

[macos]
switch:
  nix run nix-darwin -- switch --flake ".#{{ hostname }}"

[macos]
build:
  nix run nix-darwin -- build --flake ".#{{ hostname }}"
