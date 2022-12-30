{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
            name = "Raspberry Pi Linux kernel";

            src = pkgs.fetchFromGitHub {
              owner = "raspberrypi";
              repo = "linux";
              rev = "45d339389bb85588b8045dd40a00c54d01e2e711";
              sha256 = "Z/0TVDYRPDucCiP1aqc6B2vJLxdg1ecrUhrtPI2037I=";
            };

            enableParallelBuilding = true;
            makeFlags =
              [ "ARCH=arm" "CROSS_COMPILE=armv6l-unknown-linux-gnueabihf-" "LLVM=1" ];
            nativeBuildInputs = with pkgs.buildPackages; [
              llvm_14
              lld_14
              clang_14
              bison
              flex
              openssl
              bc
              ncurses
              perl
            ];

            configurePhase = ''
              patchShebangs scripts/config

              make $makeFlags bcmrpi_defconfig
            '';

            buildPhase = ''
              make $makeFlags zImage dtbs
            '';

            installPhase = ''
              cp arch/arm/boot/zImage $out/kernel.img
              cp arch/arm/boot/dts/*rpi-zero*.dtb $out/
            '';
          };
      });
}
