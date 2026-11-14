{
  description = "yet another ai chat client for nvim";
  inputs = {
    nixpkgs.url = "github:tacogips/nixpkgs-security/4a5495d1c0a7c62200b55deeeecb64f03b093056";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bun
            just
            "typescript-language-server"
          ];
          shellHook = '''';
        };
      }
    );
}
