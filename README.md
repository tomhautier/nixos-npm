# nixos-npm

The purpose of this project is to be able to build a node project with a library that need to be patch because
it install an external binary. In this case the package is compress-images, which call the package jpeg-recompress-bin 
that cause this problem

The first step is to build the jpeg-recompress-bin (for now, this git project just include this step)
Put it within compress-images while building it.
Put it in the more global project.

The builder for building jpeg-recompresscan be call with the command:
nix-build -E 'let pkgs = import <nixpkgs> { }; in pkgs.callPackage ./build-jpeg-recompress-bin.nix {}'