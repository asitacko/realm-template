module Pages.Index exposing (Config, Model, Msg, app, main)

import Browser as B
import Element as E
import Json.Decode as JD
import Realm as R
import Widgets.Base as Base


type alias Config =
    { base : Base.Config
    }


type alias Model =
    { config : Config
    , base : Base.Model
    }


type Msg
    = BaseMsg Base.Msg


init : R.In -> Config -> ( Model, Cmd (R.Msg Msg) )
init _ c =
    ( { config = c, base = Base.init c.base }, Cmd.none )


update : R.In -> Msg -> Model -> ( Model, Cmd (R.Msg Msg) )
update _ msg m =
    case msg of
        BaseMsg imsg ->
            Base.update (BaseMsg >> R.Msg) imsg m.base
                |> Tuple.mapFirst (\b -> { m | base = b })


document : R.In -> Model -> B.Document (R.Msg Msg)
document in_ model =
    view model
        |> Base.view model.base (BaseMsg >> R.Msg)
        |> R.document in_


view : Model -> E.Element (R.Msg Msg)
view _ =
    E.column [ E.centerX, E.centerY, E.width (E.px 400) ]
        [ E.el [ E.centerX ] <| E.text "Welcome"
        ]


config : JD.Decoder Config
config =
    JD.field "base" Base.config |> JD.andThen (Config >> JD.succeed)


app : R.App Config Model Msg
app =
    R.App config init update R.sub0 document


main =
    R.app app
