use crate::prelude::*;
use diesel::prelude::*;

pub fn register_user(in_: &In, email: &str, name: &str, password: &str) -> FResult<i32> {
    use crate::schema::teja_user;

    let mut form = Form::new(in_);
    form.c1("email", email, validators::email_valid)?;
    form.c1("name", name, validators::name_valid)?;
    form.c1("password", password, validators::password_valid)?;
    if form.invalid() {
        return Ok(form.errors());
    }

    let password = realm::base::hash_password(password)?;

    in_.conn.transaction(|| {
        let uid: i32 = diesel::insert_into(teja_user::table)
            .values((
                teja_user::name.eq(name),
                teja_user::email.eq(email),
                teja_user::password.eq(password),
                teja_user::status.eq("email_not_confirmed"),
                teja_user::created_on.eq(in_.now),
                teja_user::updated_on.eq(in_.now),
            ))
            .returning(teja_user::id)
            .get_result(in_.conn)?;
        // TODO: send email
        Ok(Ok(uid))
    })
}
