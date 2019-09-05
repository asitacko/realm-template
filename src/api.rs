use crate::prelude::*;
use serde::ser::SerializeMap;

pub enum Api<T>
where
    T: serde::ser::Serialize,
{
    Success(T),
    Error(String),
    // FieldErrors(std::collections::HashMap<String, String>),
}

pub fn success<T>(result: T) -> Result<realm::Response>
where
    T: serde::ser::Serialize,
{
    Api::Success(result).with_title("foo")
}

pub fn error<T>(message: &str) -> Api<T>
where
    T: serde::ser::Serialize,
{
    Api::Error(message.into())
}

impl<T> realm::Page for Api<T>
where
    T: serde::ser::Serialize,
{
    const ID: &'static str = "Pages.Api";
}

impl<T> serde::Serialize for Api<T>
where
    T: serde::ser::Serialize,
{
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        match self {
            Api::Success(r) => {
                let mut map = serializer.serialize_map(None)?;
                map.serialize_entry("success", &true)?;
                map.serialize_entry("result", r)?;
                map.end()
            }
            Api::Error(message) => {
                let mut map = serializer.serialize_map(None)?;
                map.serialize_entry("success", &false)?;
                map.serialize_entry("error", message)?;
                map.end()
            }
        }
    }
}
