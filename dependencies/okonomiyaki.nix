{ lib, buildPythonPackage, fetchPypi,
  attrs, jsonschema, six, zipfile2, distro }:
buildPythonPackage rec {
  pname = "okonomiyaki";
  version = "1.3.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1dw9di7s92z201lwq7aqy5h9h53af73ffx6pnl5iz3lnfi0zf85p";
  };
  propagatedBuildInputs = [ attrs jsonschema six zipfile2 distro ];
  doCheck = false;
}
