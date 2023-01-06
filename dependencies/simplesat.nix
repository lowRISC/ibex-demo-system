{ lib, buildPythonPackage, fetchPypi,
  okonomiyaki, attrs, six, enum34
}:
buildPythonPackage rec {
  pname = "simplesat";
  version = "0.8.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0n6qm2gzwji19ykp3i6wm6vjw7dnn92h2flm42708fxh6lkz6hqr";
  };
  propagatedBuildInputs = [ okonomiyaki attrs six enum34 ];
  doCheck = false;
}
