use crate::prelude::*;
use realm::Page as P;

#[realm_page(id = "Pages.Register")]
struct Page {
    base: widgets::Base,
    form: FormErrors,
}

pub fn get(in_: &In) -> Result<realm::Response> {
    if in_.name().is_some() {
        return crate::routes::index::redirect(in_);
    };

    Page {
        base: widgets::base(in_)?,
        form: FormErrors::new(),
    }
    .with_title("Register")
}

pub fn redirect(in_: &In) -> Result<realm::Response> {
    get(in_).map(|r| r.with_url(crate::reverse::register()))
}

pub fn post(in_: &In, name: String, email: String, password: String) -> Result<realm::Response> {
    if in_.name().is_some() {
        return crate::routes::index::redirect(in_);
    };

    let user_agent = match in_.user_agent() {
        Some(ua) => ua,
        None => {
            return crate::http404(in_, "user agent not set");
        }
    };

    match foo_bl::register_user(in_.mn(), email.as_str(), name.as_str(), password.as_str())? {
        Ok(_) => (),
        Err(form_errors) => {
            return Page {
                base: widgets::base(in_)?,
                form: form_errors,
            }
            .with_title("Register")
        }
    }

    let (uid, name, sid) = match foo_bl::log_user_in(
        in_.mn(),
        email.as_str(),
        password.as_str(),
        user_agent.as_str(),
        in_.remote_ip.as_str(),
    )? {
        Ok(t) => t,
        Err(e) => unreachable!(format!("impossible happened: {:?}", e)),
    };

    in_.set_ud(uid, name, sid);

    crate::routes::index::redirect(in_)
}
