use crate::prelude::*;
use diesel::prelude::*;

pub fn log_user_in(
    in_: &In,
    email: &str,
    password: &str,
    user_agent: &str,
    ip: &str,
) -> FResult<(i32, String, i32)> {
    use crate::schema::teja_session;
    use crate::schema::teja_user;

    let mut form = Form::new(in_);
    form.c1("email", email, validators::email_valid)?;
    form.c1("password", password, validators::password_valid)?;
    if form.invalid() {
        return Ok(form.errors());
    }

    let r: Result<(_, _, _)> = teja_user::table
        .select((teja_user::id, teja_user::name, teja_user::password))
        .filter(teja_user::email.eq(email))
        .filter(teja_user::status.not_ilike("left_company"))
        .first(in_.conn)
        .map_err(|e| e.into());

    let (uid, name, hash): (i32, String, String) = match r {
        Ok(t) => t,
        Err(_) => {
            // TODO: do exact error check
            form.add_error("email", email, "email not found");
            return Ok(form.errors());
        }
    };

    if !realm::base::verify_password(&password, hash.as_str())? {
        form.add_error("password", password, "incorrect password");
        return Ok(form.errors());
    }

    let sid = diesel::insert_into(teja_session::table)
        .values((
            teja_session::last_ip.eq(ip),
            teja_session::user_agent.eq(user_agent),
            teja_session::created_on.eq(in_.now),
            teja_session::updated_on.eq(in_.now),
            teja_session::user_id.eq(uid),
        ))
        .returning(teja_session::id)
        .get_result(in_.conn)?;

    Ok(Ok((uid, name, sid)))
}
