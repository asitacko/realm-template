module Pages.Register exposing (Config, main)

import Actions
import Browser as B
import Element as E
import Element.Input as EI
import Json.Decode as JD
import Realm as R
import Realm.Ports as RP
import Realm.Utils as U
import Types as T
import Widgets.Base as Base


type alias Config =
    { base : Base.Config
    , form : U.Form
    }


type alias Model =
    { config : Config
    , base : Base.Model
    , password1 : Field
    , password2 : Field
    , name : Field
    , email : Field
    }


type Msg
    = Password1 String
    | Password2 String
    | Email String
    | Name String
    | Submit
    | BaseMsg Base.Msg


init : R.In -> Config -> ( Model, Cmd (R.Msg Msg) )
init in_ c =
    let
        m =
            { config = c
            , password1 = fi "password" in_ c.form
            , password2 = fi "password" in_ c.form
            , email = fi "email" in_ c.form
            , name = fi "name" in_ c.form
            , base = Base.init c.base
            }
    in
    ( m, Cmd.none )


update : R.In -> Msg -> Model -> ( Model, Cmd (R.Msg Msg) )
update _ msg m =
    case msg of
        Password1 u ->
            ( { m | password1 = field m.password1 u }, Cmd.none )

        Password2 u ->
            ( { m | password2 = password2 m u }, Cmd.none )

        Email u ->
            ( { m | email = field m.email u }, Cmd.none )

        Name u ->
            ( { m | name = field m.name u }, Cmd.none )

        BaseMsg imsg ->
            Base.update (BaseMsg >> R.Msg) imsg m.base
                |> Tuple.mapFirst (\b -> { m | base = b })

        Submit ->
            case T.name m.name.value of
                Ok name ->
                    ( m
                    , Actions.register m.email.value
                        name
                        m.password1.value
                        |> RP.submit
                    )

                _ ->
                    ( m, Cmd.none )


document : R.In -> Model -> B.Document (R.Msg Msg)
document in_ model =
    view model
        |> Base.view model.base (BaseMsg >> R.Msg)
        |> R.document in_


view : Model -> E.Element (R.Msg Msg)
view m =
    E.column [ E.centerX, E.centerY, E.width (E.px 400) ]
        [ E.text "Register"
        , EI.email []
            { onChange = Email >> R.Msg
            , text = m.email.value
            , placeholder =
                Just (EI.placeholder [] (E.text "email@domain.com"))
            , label = EI.labelLeft [] (E.text "Email")
            }
        , fieldError m.email
        , EI.text []
            { onChange = Name >> R.Msg
            , text = m.name.value
            , placeholder =
                Just (EI.placeholder [] (E.text "your name"))
            , label = EI.labelLeft [] (E.text "Name")
            }
        , fieldError m.name
        , EI.newPassword []
            { onChange = Password1 >> R.Msg
            , show = False
            , text = m.password1.value
            , placeholder =
                Just (EI.placeholder [] (E.text "password"))
            , label = EI.labelLeft [] (E.text "Password")
            }
        , fieldError m.password1
        , EI.newPassword []
            { onChange = Password2 >> R.Msg
            , show = False
            , text = m.password2.value
            , placeholder =
                Just (EI.placeholder [] (E.text "repeat the password"))
            , label = EI.labelLeft [] (E.text "Confirm Password")
            }
        , fieldError m.password2
        , submitButton m
        ]


fieldValid : Field -> Bool
fieldValid f =
    f.value /= "" && f.error == Nothing


isValid : Model -> Bool
isValid m =
    List.all fieldValid [ m.name, m.email, m.password1, m.password2 ]


submitButton : Model -> E.Element (R.Msg Msg)
submitButton m =
    if isValid m then
        EI.button [] { onPress = Just (R.Msg Submit), label = E.text "Register" }

    else
        E.none


config : JD.Decoder Config
config =
    JD.map2 Config
        (JD.field "base" Base.config)
        (JD.field "form" U.form)


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


password2 : Model -> String -> Field
password2 m v =
    if String.length v == 0 && m.password2.edited then
        { value = v, error = Just "Field is required", edited = True }

    else if m.password1.error == Nothing && v /= m.password1.value then
        { value = v, error = Just "Both passwords must match.", edited = True }

    else
        { value = v, error = Nothing, edited = True }


fieldError : Field -> E.Element (R.Msg Msg)
fieldError f =
    case f.error of
        Just e ->
            E.text <| "Error: " ++ e

        Nothing ->
            E.none


app : R.App Config Model Msg
app =
    R.App config init update R.sub0 document


main =
    R.app app
