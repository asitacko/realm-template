#[macro_use]
extern crate diesel;

#[macro_use]
extern crate lazy_static;

mod log_user_in;
pub mod prelude;
mod register_user;
mod schema;
pub mod validators;

pub use log_user_in::log_user_in;
pub use register_user::register_user;
