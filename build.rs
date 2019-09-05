fn main() {
    let output = std::process::Command::new("doit")
        .arg("elm")
        .output()
        .unwrap();

    if !output.status.success() {
        eprintln!("doit elm failed");
        eprintln!("stdout: {}", std::str::from_utf8(&output.stdout).unwrap());
        eprintln!("stderr: {}", std::str::from_utf8(&output.stderr).unwrap());
        panic!("failing deployment");
    }

    // ideally we should rerun if any elm file has changed. feeling lazy to write the
    // glob code.
    //
    // on heroku, this much is sufficient as on every release following def changes.
    // locally we can call dodo elm (probably more frequently than cargo run anyways)
    println!("cargo:rerun-if-changed=.git/refs/heads/master");
}
