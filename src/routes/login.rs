use crate::prelude::*;
use realm::Page as P;

#[realm_page(id = "Pages.Login")]
struct Page {
    base: widgets::Base,
    form: FormErrors,
}

pub fn get(in_: &In) -> Result<realm::Response> {
    if in_.name().is_some() {
        return crate::routes::index::redirect(in_);
    };

    Page {
        form: FormErrors::new(),
        base: widgets::base(in_)?,
    }
    .with_title("Login")
}

pub fn redirect(in_: &In) -> Result<realm::Response> {
    get(in_).map(|r| r.with_url(crate::reverse::login()))
}

pub fn post(in_: &In, email: String, password: String) -> Result<realm::Response> {
    if in_.name().is_some() {
        return crate::routes::index::redirect(in_);
    };

    let user_agent = match in_.user_agent() {
        Some(ua) => ua,
        None => {
            return crate::http404(in_, "user agent not set");
        }
    };

    let (uid, name, sid) = match foo_bl::log_user_in(
        in_.mn(),
        email.as_str(),
        password.as_str(),
        user_agent.as_str(),
        in_.remote_ip.as_str(),
    )? {
        Ok(t) => t,
        Err(form_errors) => {
            return Page {
                base: widgets::base(in_)?,
                form: form_errors,
            }
            .with_title("Login")
        }
    };

    in_.set_ud(uid, name, sid);

    crate::routes::index::redirect(in_)
}
