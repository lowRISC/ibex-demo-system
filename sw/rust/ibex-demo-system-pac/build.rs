use std::env;
use std::fs;
use std::process::Command;

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
    let out_file = format!("{out}/ibex_demo_system_pac.rs");
    fs::write(&out_file, generated.lib_rs).unwrap();

    let _ = Command::new("rustfmt").arg(out_file).status();

    fs::write(
        format!("{out}/lib.rs"),
        format!(r#"#[path="{out}/ibex_demo_system_pac.rs"] mod ibex_demo_system_pac;"#),
    )
    .unwrap();
}
