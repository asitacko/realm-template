use crate::prelude::*;
use diesel::prelude::*;

pub fn get(in_: &In) -> Result<realm::Response> {
    if !is_test() {
        return http404(in_, "server not running in test mode");
    }

    Ok(realm::Response::Http(
        in_.ctx.response(
            r#"<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Test</title>
        <meta name="viewport" content="width=device-width" />
    </head>
    <body>
        <script src='/static/test.js'></script>
    </body>
</html>"#
                .into(),
        )?,
    ))
}

pub fn reset_db(in_: &In) -> Result<realm::Response> {
    if !is_test() {
        return http404(in_, "server not running in test mode");
    }

    diesel::sql_query("DROP SCHEMA IF EXISTS test CASCADE;").execute(in_.conn)?;

    let output = std::process::Command::new("psql")
        .args(&["-d", "foo_db", "-f", "schema.sql"])
        .output()
        .unwrap();

    if !output.status.success() {
        eprintln!("psql failed");
        eprintln!("stdout: {}", std::str::from_utf8(&output.stdout).unwrap());
        eprintln!("stderr: {}", std::str::from_utf8(&output.stderr).unwrap());
        return Err(failure::err_msg("psql failed"));
    };

    in_.logout();

    Ok(realm::Response::Http(in_.ctx.response("ok\n".into())?))
}
