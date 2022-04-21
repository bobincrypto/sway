pub mod defaults;
pub mod parameters;

use anyhow::{anyhow, Result};
use forc_util::println_yellow_err;
use rustc_version::{version, Version};
use std::fs::File;
use std::io::Read;
use std::path::Path;

/// The `forc` crate version formatted with the `v` prefix. E.g. "v1.2.3".
///
/// This git tag is used during `Manifest` construction to pin the version of the implicit `std`
/// dependency to the `forc` version.
pub const SWAY_GIT_TAG: &str = concat!("v", clap::crate_version!());

pub(crate) fn check_rust_version() -> Result<()> {
    let rustc_version = match version() {
        Ok(v) => v,
        Err(e) => {
            return Err(anyhow!("Could not locate rustc version due to:\n\n{}", e));
        }
    };

    let cargo_file = concat!(env!("CARGO_MANIFEST_DIR"), "/Cargo.toml");
    let toml_path = Path::new(&cargo_file);

    let mut file = File::open(toml_path)?;
    let mut toml = String::new();
    file.read_to_string(&mut toml)?;

    let cargo_toml: toml::Value = toml::de::from_str(&toml)?;

    if let Some(table) = cargo_toml.as_table() {
        if let Some(package) = table.get("package") {
            if let Some(version) = package.get("rust-version") {
                let version_str = &version.as_str().unwrap();
                let forc_rustc_version = Version::parse(version_str)?;
                if rustc_version > forc_rustc_version {
                    let warning = format!(
                        "\nFound rustc version {}, which is greater than the suggested version {}\n",
                        &rustc_version, &forc_rustc_version
                    );
                    println_yellow_err(&warning);
                }
                return Ok(());
            }
        }
    }

    return Err(anyhow!("Failed to read rust-version from forc/Cargo.toml"));
}

#[cfg(test)]
mod tests {
    use super::check_rust_version;

    #[test]
    fn test_check_rust_version_returns_ok_when_using_forc_cargo_toml() {
        assert_eq!(check_rust_version().unwrap(), ());
    }
}
