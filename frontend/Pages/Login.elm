module Pages.Login exposing (Config, Model, Msg, app, main)

import Actions
import Browser as B
import Element as E
import Element.Input as EI
import Json.Decode as JD
import Realm as R
import Realm.Ports as RP
import Realm.Utils as U
import Widgets.Base as Base


type alias Config =
    { form : U.Form
    , base : Base.Config
    }


type alias Model =
    { config : Config
    , email : Field
    , password : Field
    , base : Base.Model
    }


type Msg
    = Username String
    | Password String
    | BaseMsg Base.Msg
    | Submit


init : R.In -> Config -> ( Model, Cmd (R.Msg Msg) )
init in_ c =
    ( { config = c
      , email = fi "email" in_ c.form
      , password = fi "password" in_ c.form
      , base = Base.init c.base
      }
    , Cmd.none
    )


update : R.In -> Msg -> Model -> ( Model, Cmd (R.Msg Msg) )
update _ msg m =
    case msg of
        Username u ->
            ( { m | email = field m.email u }, Cmd.none )

        Password u ->
            ( { m | password = field m.password u }, Cmd.none )

        BaseMsg imsg ->
            Base.update (BaseMsg >> R.Msg) imsg m.base
                |> Tuple.mapFirst (\b -> { m | base = b })

        Submit ->
            ( m, Actions.login m.email.value m.password.value |> RP.submit )



-- VIEW


document : R.In -> Model -> B.Document (R.Msg Msg)
document in_ model =
    view model
        |> Base.view model.base (BaseMsg >> R.Msg)
        |> R.document in_


view : Model -> E.Element (R.Msg Msg)
view m =
    E.column [ E.centerX, E.centerY, E.width (E.px 400) ]
        [ E.text "Login"
        , EI.email []
            { onChange = Username >> R.Msg
            , text = m.email.value
            , placeholder =
                Just (EI.placeholder [] (E.text "email"))
            , label = EI.labelLeft [] (E.text "Username")
            }
        , fieldError m.email
        , EI.currentPassword []
            { onChange = Password >> R.Msg
            , show = False
            , text = m.password.value
            , placeholder =
                Just (EI.placeholder [] (E.text "password"))
            , label = EI.labelLeft [] (E.text "Password")
            }
        , fieldError m.password
        , submitButton m
        ]


fieldValid : Field -> Bool
fieldValid f =
    f.edited && f.error == Nothing


isValid : Model -> Bool
isValid m =
    List.all fieldValid [ m.email, m.password ]


submitButton : Model -> E.Element (R.Msg Msg)
submitButton m =
    if isValid m then
        EI.button [] { onPress = Just (R.Msg Submit), label = E.text "Login" }

    else
        E.none


fieldError : Field -> E.Element (R.Msg Msg)
fieldError f =
    case f.error of
        Just e ->
            E.text <| "Error: " ++ e

        Nothing ->
            E.none


config : JD.Decoder Config
config =
    JD.map2 Config
        (JD.field "form" U.form)
        (JD.field "base" Base.config)


app : R.App Config Model Msg
app =
    R.App config init update R.sub0 document


main =
    R.app app


type alias Field =
    { value : String
    , error : Maybe String
    , edited : Bool
    }


field : Field -> String -> Field
field f v =
    if String.length v == 0 && f.edited then
        { value = v, error = Just "Field is required", edited = True }

    else if String.length v > 30 then
        { value = v, error = Just "Max length 30", edited = True }

    else
        { value = v, error = Nothing, edited = True }


fi : String -> R.In -> U.Form -> Field
fi name in_ form =
    let
        val =
            U.val name in_ form
    in
    { value = val, edited = val /= "", error = U.err name form }
