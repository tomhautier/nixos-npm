{ lib, pkgs, buildNpmPackage, fetchFromGitHub }:

let  dataPath = pkgs.copyPathToStore ./packages-to-patch;
jpeg-recompress-bin = pkgs.runCommand "jpeg-recompress-bin" { } ''
  mkdir -p $out/jpeg-recompress-bin/vendor/linux
  cp ${dataPath}/jpeg-recompress-bin/vendor/linux/jpeg-recompress $out/jpeg-recompress-bin/vendor/linux
'';
in
buildNpmPackage rec {
  pname = "jpeg-recompress-bin";
  version = "5.1.2";
  rootPackagesDir = pkgs.copyPathToStore ./packages-to-patch;


  src = fetchFromGitHub {
    owner = "imagemin";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cx/xBi11j+U9EW6d8DINYLwvNnOnH1wLDXj1DPbCeoU=";
  };



   prePatch = ''
   echo "node -v"
   cp ${rootPackagesDir}/jpeg-recompress-bin/lib/index.patch index.patch;ls;
   '';
   postPatch = ''
    echo "LIST OF SCRIPT"
    npm run
    cp  ${rootPackagesDir}/jpeg-recompress-bin/package-lock.json package-lock.json;
    ls;
   '';
  npmDepsHash = "sha256-Pp3QgZPGKc0EVzJ3LcWXpQ3h5i9pvtEUOM0QvpHSQOo=";

  patches = ["${rootPackagesDir}/jpeg-recompress-bin/lib/index.patch" "${rootPackagesDir}/jpeg-recompress-bin/package.patch"];

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts --loglevel verbose" ];

  makeCacheWritable = true;

  NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "Minify size your images";
    homepage = "https://flood.js.org";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ winter ];
  };
}