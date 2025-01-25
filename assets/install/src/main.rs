use dialoguer::{theme::ColorfulTheme, MultiSelect};
use serde::Deserialize; // Trait needed for deserialization
use std::fs; // For file operations
use std::process::{Command, Stdio};

#[derive(Debug, Deserialize)]
struct Script {
    name: String,
    cmds_check_install: Vec<String>,
    cmds_installation: Vec<String>,

    #[serde(default)]
    is_installed: bool,
}

impl Script {
    fn item_string(&self) -> String {
        match self.is_installed {
            true => format!("{:15} \t \x1b[0m[\x1b[32mInstalled\x1b[0m]", self.name),
            false => format!("{} ", self.name),
        }
    }
}

fn update_scripts(scripts: &mut Vec<Script>) {
    for script in scripts {
        script.is_installed = script.cmds_check_install.iter().all(|cmd| {
            match Command::new("sh")
                .arg("-c")
                .arg(cmd)
                .stdout(Stdio::null())
                // .stderr(Stdio::null())
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

        // let mut work = Vec::new();
        //
        // for item in selection.iter() {
        //     let script = &scripts[*item];
        //     if !script.is_installed {
        //         work.push(script);
        //     }
        // }

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

    Ok(())
}
