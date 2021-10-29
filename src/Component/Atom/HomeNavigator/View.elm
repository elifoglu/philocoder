module HomeNavigator.View exposing (viewHomeNavigator)

import App.Msg exposing (Msg)
import Html exposing (Html, a, b, text)
import Html.Attributes exposing (class, href, style)


viewHomeNavigator : Html Msg
viewHomeNavigator =
    a [ class "headerItem homeNavigator", href "/" ]
        [ b [ style "font-weight" "bolder" ]
            [ text "philocoder" ]
        ]
