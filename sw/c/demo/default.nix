{
  rules,
  common,
  lowrisc-toolchain-gcc-rv32imcb,
}:
with common.rules_cc; {
  hello_world = binary {
    name = "hello_world";
    deps = [hello_world/main.c common];
  };
}
