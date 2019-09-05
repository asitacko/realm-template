use crate::prelude::*;
use http::method::Method;

pub fn magic(in_: &In) -> Result<realm::Response> {
    let mut input = realm::request_config::RequestConfig::new(&in_.ctx.request)?;
    match (in_.ctx.request.uri().path(), in_.ctx.request.method()) {
        ("/api/is_name_available/", &Method::GET) => {
            let name = input.get("name", false)?;
            crate::routes::api::is_name_available::post(in_, name)
        }
        ("/storybook/", &Method::GET) => crate::routes::storybook::get(in_),
        ("/test/", &Method::GET) => crate::routes::test::get(in_),
        ("/iframe/", &Method::GET) => crate::routes::iframe::get(in_),
        ("/", &Method::GET) => crate::routes::index::get(in_),
        ("/login/", &Method::GET) => crate::routes::login::get(in_),
        ("/login/", &Method::POST) => {
            let email = input.get("email", false)?;
            let password = input.get("password", false)?;
            crate::routes::login::post(in_, email, password)
        }
        ("/register/", &Method::GET) => crate::routes::register::get(in_),
        ("/register/", &Method::POST) => {
            let email = input.get("email", false)?;
            let password = input.get("password", false)?;
            let name = input.get("name", false)?;
            crate::routes::register::post(in_, name, email, password)
        }
        ("/logout/", &Method::GET) => crate::routes::logout::get(in_),
        _ => http404(in_, "no matching route"),
    }
}
