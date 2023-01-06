{ lib, buildPythonPackage, fetchPypi,
  pyyaml }:
buildPythonPackage rec {
  pname = "ipyxact";
  version = "0.3.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "09rv8zn6gqwhdnwgx246mz9biln0q71hsxjf6sb9ilhan75fsn0z";
  };
  propagatedBuildInputs = [ pyyaml ];
  doCheck = false;
}
