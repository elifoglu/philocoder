module Breadcrumb.View exposing (..)

import App.Model exposing (Initializable(..), Model, Page(..))
import App.Msg exposing (Msg)
import Home.View exposing (viewIconsDiv)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (Html, b, text)
import Html.Attributes exposing (class)


viewBreadcrumb : Model -> List (Html Msg)
viewBreadcrumb model =
    case model.activePage of
        TagPage initializable ->
            case initializable of
                NonInitialized _ ->
                    [ viewHomeNavigator False ]

                Initialized initialized ->
                    [ viewHomeNavigator False
                    , viewHeaderText " >> "
                    , viewHeaderText initialized.tag.name
                    ]

        HomePage _ _ _ _ ->
            [ viewHomeNavigator True, viewIconsDiv model ]

        BioPage _ ->
            [ viewIconsDiv model ]

        _ ->
            [ viewHomeNavigator False, viewIconsDiv model ]


viewHeaderText : String -> Html Msg
viewHeaderText txt =
    b [ class "headerItem" ]
        [ text txt ]
