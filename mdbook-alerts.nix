{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "mdbook-alerts";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "lambdalisue";
    repo = "rs-mdbook-alerts";
    rev = "v${version}";
    hash = "sha256-YlCvsDdWuoajuXt2hOGx7jW+lmLeMOSQ809bG9ZBaBY=";
  };

  cargoHash = "sha256-OuZo8QTE5Z1991S5CEkfxlXghQbnalt1UGNs4KozmEk=";

  meta = with lib; {
    description = "mdBook preprocessor to add GitHub Flavored Markdown's Alerts to your book";
    mainProgram = "mdbook-alerts";
    license = licenses.mit;
    maintainers = with maintainers; [ adtya ];
    homepage = "https://github.com/lambdalisue/rs-mdbook-alerts";
  };
}
