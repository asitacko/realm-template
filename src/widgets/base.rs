use crate::prelude::*;

#[derive(Serialize)]
pub struct Base {
    name: Option<String>,
}

pub fn base(in_: &In) -> Result<Base> {
    Ok(Base { name: in_.name() })
}
