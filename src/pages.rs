use crate::prelude::*;

#[derive(Serialize)]
pub struct NotFound {
    message: String,
    url: String,
}

impl realm::Page for NotFound {
    const ID: &'static str = "Pages.NotFound";
}

pub fn not_found(in_: &In, message: &str) -> NotFound {
    NotFound {
        message: message.into(),
        url: in_.ctx.request.uri().path().into(),
    }
}
