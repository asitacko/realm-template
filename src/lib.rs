#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate realm_macros;

pub mod api;
pub mod forward;
pub mod pages;
pub mod prelude;
pub mod reverse;
pub mod routes;
pub mod widgets;

pub fn http404(in_: &realm::base::In, msg: &str) -> Result<realm::Response, failure::Error> {
    use realm::Page;
    pages::not_found(in_, msg).with_title(msg)
}
