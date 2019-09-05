table! {
    django_migrations (id) {
        id -> Int4,
        app -> Varchar,
        name -> Varchar,
        applied -> Timestamptz,
    }
}

table! {
    teja_session (id) {
        id -> Int4,
        last_ip -> Text,
        user_agent -> Text,
        created_on -> Timestamptz,
        updated_on -> Timestamptz,
        user_id -> Int4,
    }
}

table! {
    teja_user (id) {
        id -> Int4,
        name -> Text,
        email -> Varchar,
        password -> Text,
        status -> Text,
        created_on -> Timestamptz,
        updated_on -> Timestamptz,
    }
}

joinable!(teja_session -> teja_user (user_id));

allow_tables_to_appear_in_same_query!(django_migrations, teja_session, teja_user,);
