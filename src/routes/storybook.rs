use crate::prelude::*;

pub fn get(in_: &In) -> Result<realm::Response> {
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
        <script src='/static/storybook.js'></script>
    </body>
</html>"#
                .into(),
        )?,
    ))
}
