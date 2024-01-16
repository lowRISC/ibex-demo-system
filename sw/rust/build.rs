// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//! This Cargo build script locates and uses the `link.ld` linker script.
//!
//! This build script can be used by a crate from its Cargo.toml:
//!
//! ```toml
//! [package]
//! ...
//! build = "../path/to/build.rs"
//! ```
//!
//! Build scripts are run with their working directory as the root of the
//! crate being built. We must find the path to the Cargo workspace in order
//! to get the correct path to the `link.ld` script.

use std::path::PathBuf;
use std::process::Command;

fn main() {
    // Ask Cargo for the path of the workspace.
    let workspace_path = Command::new(env!("CARGO"))
        .arg("locate-project")
        .arg("--workspace")
        .arg("--message-format=plain")
        .output()
        .expect("failed to locate project using cargo")
        .stdout;
    let workspace_path = std::str::from_utf8(&workspace_path).expect("path to workspace not UTF-8");
    let workspace_path = PathBuf::from(workspace_path);
    let workspace_path = workspace_path.parent().expect("failed to get parent");

    // Find the path of the linker script relative to the workspace.
    let linker_script_path = workspace_path.join("../common/link.ld");
    let linker_script_path = linker_script_path.display();

    // Use the linker script and rebuild crates if it changes.
    println!("cargo:rerun-if-changed={linker_script_path}");
    println!("cargo:rustc-link-arg=-T{linker_script_path}");
}
