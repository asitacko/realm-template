use crate::prelude::*;

lazy_static! {
    static ref EMAIL_REGEX: regex::Regex = regex::Regex::new("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$").unwrap();
}

fn check(valid: bool, msg: &str) -> Result<Option<String>> {
    if valid {
        Ok(None)
    } else {
        Ok(Some(msg.to_string()))
    }
}

pub fn email_valid(_: &In, value: &str) -> Result<Option<String>> {
    check(EMAIL_REGEX.is_match(value), "Email is not valid.")
}

pub fn name_valid(_: &In, value: &str) -> Result<Option<String>> {
    check(!value.is_empty(), "Name is required.")
}

pub fn password_valid(_: &In, value: &str) -> Result<Option<String>> {
    check(value.len() > 7, "Minimum password length is 8.")
}
