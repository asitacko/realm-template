use crate::prelude::*;

pub fn get(in_: &In) -> Result<realm::Response> {
    in_.logout();
    crate::routes::index::redirect(in_)
}
