{ lib, buildPythonPackage, fetchPypi,
  jinja2, setuptools_scm, simplesat
}:
buildPythonPackage rec {
  pname = "edalize";
  version = "0.3.3";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1734aprwzm0z2l60xapqrfxxw747n9h9fflv3n0x4iaradf75abj";
  };
  SETUPTOOLS_SCM_PRETEND_VERSION = "${version}";
  nativeBuildInputs = [ setuptools_scm ];
  propagatedBuildInputs = [ jinja2 simplesat ];
  doCheck = false;
}
