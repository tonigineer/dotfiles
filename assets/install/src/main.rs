use dialoguer::{theme::ColorfulTheme, MultiSelect};
use serde::Deserialize; // Trait needed for deserialization
use std::fs; // For file operations
use std::process::{Command, Stdio};

#[derive(Debug, Deserialize)]
struct Script {
    name: String,
    category: String,
    packages: Vec<String>,
    configs: Vec<String>,
    cmds_check_install: Vec<String>,
    cmds_installation: Vec<String>,

    #[serde(default)]
    is_installed: bool,
}

impl Script {
    fn item_string(&self) -> String {
        match self.is_installed {
            true => format!(
                "{:15} \t [{}] \x1b[0m[\x1b[32mInstalled\x1b[0m]",
                self.name, self.category
            ),
            false => format!("{:15} \t [{}]", self.name, self.category),
        }
    }
}

fn update_scripts(scripts: &mut Vec<Script>) {
    for script in scripts {
        script.is_installed = match Command::new("sh")
            .arg("-c")
            .arg(format!("yay -Q {}", script.packages.join(" ")))
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
        {
            Ok(status) => status.success(),
            Err(_) => false,
        };

        if !script.is_installed {
            continue;
        }

        script.is_installed = script.cmds_check_install.iter().all(|cmd| {
            match Command::new("sh")
                .arg("-c")
                .arg(cmd)
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .status()
            {
                Ok(status) => status.success(),
                Err(_) => false,
            }
        });

        if !script.is_installed {
            continue;
        }
        script.is_installed = script.cmds_check_install.iter().all(|cmd| {
            match Command::new("sh")
                .arg("-c")
                .arg(cmd)
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .status()
            {
                Ok(status) => status.success(),
                Err(_) => false,
            }
        });
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let json_data = fs::read_to_string("scripts.json")?;
    let mut scripts: Vec<Script> = serde_json::from_str(&json_data)?;

    loop {
        update_scripts(&mut scripts);
        let selection = MultiSelect::with_theme(&ColorfulTheme::default())
            .with_prompt("Select installation scripts!")
            .items(
                &scripts
                    .iter()
                    .map(|script| script.item_string())
                    .collect::<Vec<String>>(),
            )
            .defaults(
                &scripts
                    .iter()
                    .map(|script| script.is_installed)
                    .collect::<Vec<bool>>(),
            )
            .max_length(10)
            .report(false)
            .interact()
            .unwrap();

        let work = selection
            .iter()
            .map(|&idx| &scripts[idx])
            .filter(|script| !script.is_installed)
            .collect::<Vec<_>>();

        if work.is_empty() {
            break;
        }

        for job in work.iter() {
            println!("Running installation for {}", job.name);

            if !job.packages.is_empty() {
                println!("  installing packages ");
                match Command::new("sh")
                    .arg("-c")
                    .arg(format!("yay -S {}", job.packages.join(" ")))
                    .status()
                {
                    Ok(status) => status.success(),
                    Err(_) => panic!(),
                };
            };

            if !job.configs.is_empty() {
                match Command::new("sh")
                    .arg("-c")
                    .arg("cd $HOME/Dotfiles & ")
                    .arg(format!("stow -v -R -t $HOME {}", job.configs.join(" ")))
                    .status()
                {
                    Ok(status) => status.success(),
                    Err(_) => panic!(),
                };
            };

            if !job.cmds_installation.is_empty() {
                job.cmds_installation.iter().all(|cmd| {
                    match Command::new("sh")
                        .arg("-c")
                        .arg(cmd)
                        // .stdout(Stdio::null())
                        .status()
                    {
                        Ok(status) => status.success(),
                        Err(_) => panic!(),
                    }
                });
            }
        }
    }

    Ok(())
}
