{ lib, pkgs, buildNpmPackage, fetchFromGitHub }:

let  dataPath = pkgs.copyPathToStore ./packages-to-patch;
jpeg-recompress-bin = pkgs.runCommand "jpeg-recompress-bin" { } ''
  mkdir -p $out/jpeg-recompress-bin/vendor/linux
  cp ${dataPath}/jpeg-recompress-bin/vendor/linux/jpeg-recompress $out/jpeg-recompress-bin/vendor/linux
'';

src = ./compress-images-data/jpeg-recompress-bin;
 packageLock = builtins.fromJSON (builtins.readFile (src + "/package-lock.json"));

  # Create an array of all (meaningful) dependencies
  deps = builtins.attrValues (removeAttrs packageLock.dependencies [ "" ]);

  # Turn each dependency into a fetchurl call
  tarballs = map (p: pkgs.fetchurl { url = p.resolved; hash = p.integrity; }) deps;

  # Write a file with the list of tarballs
  tarballsFile = pkgs.writeTextFile {
    name = "tarballs";
    text = builtins.concatStringsSep "\n" tarballs;
  };
in
buildNpmPackage rec {
  pname = "jpeg-recompress-bin";
  version = "5.1.2";
  test = pkgs.copyPathToStore ./compress-images-data;


  src = fetchFromGitHub {
    owner = "imagemin";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cx/xBi11j+U9EW6d8DINYLwvNnOnH1wLDXj1DPbCeoU=";
  };



   prePatch = ''
   cp ${test}/jpeg-recompress-bin/lib/local-deps.patch local-deps.patch;ls;
   '';
   postPatch = ''
    cp  ${test}/jpeg-recompress-bin/package-lock.json package-lock.json;
    ls;
   '';
  npmDepsHash = "sha256-Pp3QgZPGKc0EVzJ3LcWXpQ3h5i9pvtEUOM0QvpHSQOo=";

  patches = ["./local-deps.patch"];

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts --loglevel verbose" ];
  npmBuildFlags = [ "--loglevel verbose" ];
  makeCacheWritable = true;

  NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "Minify size your images";
    homepage = "https://flood.js.org";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ winter ];
  };
}