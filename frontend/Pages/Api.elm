module Pages.Api exposing (main)

import Browser as B
import Element as E
import Element.Font as EF
import Html as H
import Json.Decode as JD
import Json.Encode as JE
import Realm as R


type alias Config =
    JE.Value


document : R.In -> Config -> B.Document (R.Msg ())
document in_ =
    view >> R.document in_


view : Config -> E.Element (R.Msg ())
view f =
    E.column [ E.width E.fill, E.height E.fill, EF.family [ EF.monospace ] ]
        [ E.text "API Response:"
        , E.html <| H.text (JE.encode 4 f)
        ]


app : R.App Config Config ()
app =
    R.App JD.value R.init0 R.update0 R.sub0 document


main =
    R.app app
