module HomeNavigator.View exposing (viewHomeNavigator)

import App.Msg exposing (Msg)
import Html exposing (Html, a, b, text)
import Html.Attributes exposing (class, href, style)


viewHomeNavigator : Html Msg
viewHomeNavigator =
    a [ class "headerTab", style "text-decoration" "none", href "/" ]
        [ b [ style "font-weight" "bolder" ]
            [ text "philocoder" ]
        ]
