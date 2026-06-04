{ pkgs ? import <nixpkgs> {} }:

let
  fontPaths = [
    "${pkgs.font-awesome}/share/fonts"
    "${pkgs.ibm-plex}/share/fonts"
  ];
in pkgs.mkShell {
  buildInputs = with pkgs; [
    typst
    gnumake
    cue
    font-awesome
    ibm-plex
    imagemagick
    nodePackages.cspell
  ];

  shellHook = ''
    export TYPST_FONT_PATHS="${builtins.concatStringsSep ":" fontPaths}"
  '';
}
