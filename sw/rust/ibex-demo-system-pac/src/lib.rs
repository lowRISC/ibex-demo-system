#![no_std]
#![allow(non_camel_case_types)]

pub use ibex_demo_system_pac::generic::*;
pub use ibex_demo_system_pac::*;

include!(concat!(env!("OUT_DIR"), "/lib.rs"));
