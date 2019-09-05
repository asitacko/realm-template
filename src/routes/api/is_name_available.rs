use crate::prelude::*;

pub fn post(_in_: &In, _name: String) -> Result<realm::Response> {
    api::success(true)
}
