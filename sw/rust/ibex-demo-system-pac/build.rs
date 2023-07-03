use std::env;
use std::fs;

use svd2rust::{Config, Target};

fn main() {
    println!("cargo:rerun-if-changed=ibex.svd");

    let svd = fs::read_to_string("../../../data/ibex.svd").unwrap();
    let config = Config {
        target: Target::RISCV,
        pascal_enum_values: true,
        make_mod: true,
        ..Default::default()
    };

    let generated = svd2rust::generate(&svd, &config).unwrap();

    let out = env::var("OUT_DIR").unwrap();
    fs::write(format!("{out}/ibex_demo_system_pac.rs"), generated.lib_rs).unwrap();

    fs::write(
        format!("{out}/lib.rs"),
        format!(r#"#[path="{out}/ibex_demo_system_pac.rs"] mod ibex_demo_system_pac;"#),
    )
    .unwrap();
}
