{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  name = "ringer-${version}";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "mgdm";
    repo = "ringer";
    rev = "631112a49983ce5baa5ce12344ce612dc7e999aa";
    sha256 = "0f36p931ib46hmxbrbmslx109m3fnv08slmnvkfn13v0jqkyzsmm";
  };
  buildInputs = [ ];

  checkPhase = "";
  cargoSha256 = "0mjg540wlxk3k7gdyqa6hxzjpl4ci6wrsgl57vmgyp753rdzccs4";

  meta = with lib; {
    description = "in.fingerd but in rust";
    homepage = https://github.com/mgdm/ringer;
    license = licenses.isc;
    maintainers = [ maintainers.mgdm ];
    platforms = platforms.all;
  };
}

