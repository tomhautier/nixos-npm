{ pkgs ? import <nixpkgs> {} }:

let placebo-npm = pkgs.fetchFromGitHub {
    owner  = "svanderburg";
    repo   = "placebo-npm";
    rev = "master";
    sha256 = "sha256-njbdhRcFCTPJbjM3DY715eEgB5XxI5AJ/Y2naUz7Nuc=";
  };
in
pkgs.stdenv.mkDerivation ({
    name = "derivationName";
  pname = "test"; # Escape characters that aren't allowed in a store path
   src = ./.;
  placeboJSON = builtins.toJSON ./package-placebo.json;
  passAsFile = [ "placeboJSON" ];

  buildInputs = [ pkgs.nodejs placebo-npm ];

  buildPhase = ''
    runHook preBuild
    true
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/test
    mv * $out/lib/node_modules/test
    cd $out/lib/node_modules/test

    placebo-npm --placebo $placeboJSONPath
    npm install --offline

    runHook postInstall
  '';
})


