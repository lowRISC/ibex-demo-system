{ lib, buildPythonPackage, fetchPypi }:
buildPythonPackage rec {
  pname = "zipfile2";
  version = "0.0.12";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0256m134qs045j1c8mmgii8ipkwhww9sjbc6xyawhykid34zfxkk";
  };
  doCheck = false;
}
