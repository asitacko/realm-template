module Pages.NotFound exposing (main)

import Browser as B
import Element as E
import Json.Decode as JD
import Realm as R


type alias Config =
    { message : String
    , url : String
    }


document : R.In -> Config -> B.Document (R.Msg ())
document in_ m =
    R.document in_ (view m)


view : Config -> E.Element (R.Msg ())
view model =
    E.column []
        [ E.text <| "page not found: " ++ model.url
        , E.text model.message
        ]


config : JD.Decoder Config
config =
    JD.map2 Config
        (JD.field "message" JD.string)
        (JD.field "url" JD.string)


app : R.App Config Config ()
app =
    R.App config R.init0 R.update0 R.sub0 document


main =
    R.app app
