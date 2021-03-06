module NotFound exposing (view404Div)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


view404Div : Html msg
view404Div =
    text "böyle bir sayfa/içerik yok"
