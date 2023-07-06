# Ibex demo system PAC (Peripheral Access Crate)
A Peripheral Access Crate (PAC) for the Ibex Demo System from lowRISC. See the [svd2rust](https://docs.rs/svd2rust/0.29.0/svd2rust/) documentation for more information on how to use this crate.

The Ibex demo system pac is automatically generated when imported by cargo and it is based on the ibex.svd file. 
## How to generate manually (Optional)
- Install the tooling:
    ```sh
    cargo install svd2rust && cargo install form
    ```
- Generate from the svd:
    ```sh
    svd2rust --target=riscv -i ../../../data/ibex.svd -o ./ && form -i lib.rs -o src/ && rm lib.rs && cargo fmt
    ```
- Generate the docs:
  ```sh
  cargo doc --open
  ```

## How to import on your application
1. Add this crate a dependency to the application on the .toml file.
    ```toml
    ibex_demo_system_pac = {path = "../../ibex-demo-system-pac"}
    ```
2. Import the crate to your main.rs 
    ```rust
    use ibex_demo_system_pac::Peripherals;

    #[entry]
    fn main() -> ! {
        let p = Peripherals::take().unwrap();
    }
    ```
