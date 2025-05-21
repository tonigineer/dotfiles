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
    checks: Vec<String>,
    prior_install: Vec<String>,
    post_install: Vec<String>,

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

        script.is_installed = script.checks.iter().all(|cmd| {
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
    let json_data = fs::read_to_string("./../instructions.json")?;
    let mut scripts: Vec<Script> = serde_json::from_str(&json_data)?;

    loop {
        update_scripts(&mut scripts);
        let selection = MultiSelect::with_theme(&ColorfulTheme::default())
            .with_prompt("Select Installation[s] with <SPC> and confirm with <RET>")
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
            println!("Running installation for \x1b[33m{}\x1b[0m", job.name);

            println!("\x1b[31m>\x1b[0m (1/4) Prior install commands ...");
            job.prior_install.iter().all(|cmd| {
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

            println!("\x1b[31m>\x1b[0m (2/4) Linking configs ... \x1b[0m");
            if !job.configs.is_empty() {
                match Command::new("sh")
                    .arg("-c")
                    .arg(format!(
                        "cd $HOME/Dotfiles; stow -v -R -t $HOME {}",
                        job.configs.join(" ")
                    ))
                    .status()
                {
                    Ok(status) => status.success(),
                    Err(_) => panic!(),
                };
            };

            if !job.packages.is_empty() {
                println!("\x1b[31m>\x1b[0m (3/4) Installing packages ... \x1b[0m");
                match Command::new("sh")
                    .arg("-c")
                    .arg(format!("yay -S {}", job.packages.join(" ")))
                    .status()
                {
                    Ok(status) => status.success(),
                    Err(_) => panic!(),
                };
            };

            println!("\x1b[31m>\x1b[0m (4/4) Post install commands ... \x1b[0m");
            job.post_install.iter().all(|cmd| {
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

    Ok(())
}
