module Types exposing (Name, getName, name)


type Name
    = Name String


type Error
    = Error String


type Value
    = Value String


type alias Validate v =
    Result ( Value, Error ) v


getName : Name -> String
getName (Name n) =
    n


name : String -> Validate Name
name n =
    if String.length n == 0 then
        Err ( Value n, Error "invalid name" )

    else
        Ok (Name n)
