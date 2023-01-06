{ lib, buildPythonPackage, fetchPypi,
  setuptools_scm, pyparsing, pyyaml, simplesat, ipyxact, edalize
}:
buildPythonPackage rec {
  pname = "fusesoc";
  version = "1.12.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "1065arwk1hylf4lqmgqb77fw9izgh7jaib5qnl2dqwdic11c2w44";
  };
  SETUPTOOLS_SCM_PRETEND_VERSION = "${version}"; # Hack
  nativeBuildInputs = [ setuptools_scm ];
  propagatedBuildInputs = [ pyparsing pyyaml simplesat ipyxact edalize ];
  doCheck = false;
}
