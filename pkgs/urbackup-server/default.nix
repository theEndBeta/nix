{ stdenv, zlib, curl, zstd }:

stdenv.mkDerivation rec {
  pname = "urbackup-server";
  version = "2.5.31";

  enableParallelBuilding = true;

  src = fetchTarball {
    url = "https://hndl.urbackup.org/Server/${ version }/urbackup-server-${ version }.tar.gz";
    sha256 = "05hswavmmiwws5f3y90scr4i245p04kqyik334v4nz98z5ijlv74"; # nix-prefetch-url --unpack <url>
  };

  configureFlags = [
    "--enable-embedded-cryptopp"
    "--enable-packaging"
  ];

  buildInputs = [ zlib curl zstd ];

  prePatch = ''
    substituteInPlace Makefile.am Makefile.in --replace "chmod +s" "# chmod +s"
  '';
}
