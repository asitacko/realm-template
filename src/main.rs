use amitu_base::*;

realm::realm! {middleware}

pub fn middleware(ctx: &realm::Context) -> Result<realm::Response> {
    let start = std::time::Instant::now();
    let path = ctx.request.uri().path();
    if path.starts_with("/static/") {
        return match static_content(path) {
            Ok(content) => {
                println!(
                    "ok: {:?} {} in {}",
                    ctx.request.method(),
                    path,
                    amitu_base::elapsed(start)
                );
                Ok(realm::Response::Http(
                    http::Response::builder()
                        .status(http::StatusCode::OK)
                        .body(content)?,
                ))
            }
            Err(e) => {
                eprintln!("failed to get content: {} [{:?}]", path, e);
                return Ok(realm::Response::Http(
                    http::Response::builder()
                        .status(http::StatusCode::NOT_FOUND)
                        .body(format!("no such file: {}", path).into())?,
                ));
            }
        };
    }

    let conn = connection();
    let in_ = In::from(&conn, ctx, "not implemented");

    let success;
    let mut error = "".to_string();
    let resp = match foo::forward::magic(&in_) {
        Ok(r) => {
            success = true;
            Ok(r)
        }
        Err(e) => {
            success = false;
            error = format!("{:?}", e);
            Err(e)
        }
    };

    println!(
        "{}: {:?} {:?} in {}",
        if success {
            "ok".to_string()
        } else {
            format!("err: [{:?}]", error)
        },
        ctx.request.method(),
        ctx.request.uri(),
        amitu_base::elapsed(start)
    );

    resp
}

pub fn static_content(src: &str) -> Result<Vec<u8>> {
    use std::io::Read;

    eprintln!("serve_static: {}", src);

    let path = std::fs::canonicalize(".".to_string() + src)?;
    if !path.starts_with(std::env::current_dir()?) {
        return Err(failure::err_msg("outside file rejected"));
    }

    let mut file = std::fs::File::open(&path)?;

    let mut content = Vec::new();
    file.read_to_end(&mut content)?;
    Ok(content)
}
