module HomeNavigator.View exposing (viewHomeNavigator)

import App.Msg exposing (Msg)
import Html exposing (Html, a, b, span, text)
import Html.Attributes exposing (class, href, style)


viewHomeNavigator : Bool -> Html Msg
viewHomeNavigator currentPageIsHome =
    if currentPageIsHome then
        span [ class "headerItem homeNavigator", style "cursor" "pointer" ]
            [ b [ style "font-weight" "bolder" ]
                [ text "philocoder" ]
            ]

    else
        a [ class "headerItem homeNavigator", href "/" ]
            [ b [ style "font-weight" "bolder" ]
                [ text "philocoder" ]
            ]
