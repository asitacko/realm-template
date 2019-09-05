use crate::prelude::*;
use realm::Page as P;

#[realm_page(id = "Pages.Index")]
struct Page {
    base: widgets::Base,
}

pub fn get(in_: &In) -> Result<realm::Response> {
    Page {
        base: widgets::base(in_)?,
    }
    .with_title("Welcome")
}

pub fn redirect(in_: &In) -> Result<realm::Response> {
    get(in_).map(|r| r.with_url(crate::reverse::index()))
}
