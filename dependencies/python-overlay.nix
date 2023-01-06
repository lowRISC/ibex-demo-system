pfinal: pprev: {
  ipyxact = pfinal.callPackage ./ipyxact.nix {};
  zipfile2 = pfinal.callPackage ./zipfile2.nix {};
  simplesat = pfinal.callPackage ./simplesat.nix {};
  okonomiyaki = pfinal.callPackage ./okonomiyaki.nix {};
  fusesoc = pfinal.callPackage ./fusesoc.nix {};
  edalize = pfinal.callPackage ./edalize.nix {};
}
