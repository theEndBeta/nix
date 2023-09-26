is_nixos := path_exists("/etc/NIXOS")
user := `id -un`
hostname := `uname -n`
home-manager-id := user + "@" + hostname
cmd := if is_nixos == "true" { "nixos-rebuild" } else { "home-manager" }
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
  {{ cmd }} switch --flake "{{ justfile_directory() }}#{{ target }}"

[linux]
build:
  {{ cmd }} build --flake "{{ justfile_directory() }}#{{ target }}"

[linux]
update:
  nix flake update "{{ justfile_directory() }}#{{ target }}"

[linux]
check:
  nix flake check "{{ justfile_directory() }}"

[no-cd]
pkg-build dir=".":
  nix-build -E 'with import <nixpkgs> {}; callPackage {{ dir }}/default.nix {}'
