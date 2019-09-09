module Widgets.Base exposing (Config, Model, Msg, config, init, update, view)

import Element as E
import Element.Events as EE
import Json.Decode as JD
import Realm.Ports as RP
import Realm.Utils as U
import Routes


type alias Config =
    { name : Maybe String
    }


type alias Model =
    { config : Config
    , onName : Bool
    }


type Msg
    = GoTo String
    | Hover Bool


init : Config -> Model
init c =
    { config = c, onName = False }


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update _ msg model =
    case msg of
        GoTo url ->
            ( model, RP.navigate url )

        Hover b ->
            ( { model | onName = b }, Cmd.none )


view : Model -> (Msg -> msg) -> E.Element msg -> E.Element msg
view model tagger inner =
    E.column [ E.padding 10, E.height E.fill, E.width E.fill ]
        [ header model |> E.map tagger
        , inner
        , footer model |> E.map tagger
        ]


header : Model -> E.Element Msg
header m =
    E.row [ E.width E.fill, E.spacing 10 ]
        (U.link Routes.index [ E.alignLeft ] GoTo (E.text "realm template")
            :: (case m.config.name of
                    Just name ->
                        [ showName name m
                        ]

                    Nothing ->
                        [ U.link Routes.login [ E.alignRight ] GoTo (E.text "login")
                        , U.link Routes.register
                            [ E.alignRight ]
                            GoTo
                            (E.text "register")
                        ]
               )
        )


showName : String -> Model -> E.Element Msg
showName name m =
    let
        subMenu =
            E.below <|
                E.column [ E.alignRight ]
                    [ U.link Routes.logout [ E.alignRight ] GoTo (E.text "logout")
                    ]
    in
    E.el
        ([ E.alignRight
         , EE.onMouseEnter (Hover True)
         , EE.onMouseLeave (Hover False)
         ]
            ++ (if m.onName then
                    [ subMenu ]

                else
                    []
               )
        )
    <|
        E.text name


footer : Model -> E.Element Msg
footer _ =
    E.row [ E.alignBottom, E.width E.fill, E.height E.shrink ]
        [ E.el [ E.centerX ] (E.text "footer")
        ]


config : JD.Decoder Config
config =
    JD.field "name" (JD.maybe JD.string) |> JD.andThen (Config >> JD.succeed)
