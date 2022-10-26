module Breadcrumb.View exposing (..)

import App.Model exposing (Initializable(..), Model, Page(..))
import App.Msg exposing (Msg)
import Home.View exposing (viewIcons)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (Html, b, div, text)
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

        HomePage _ _ _ ->
            viewHomeNavigator True :: viewIcons model

        BioPage _ ->
            [ div [ class "bioPageIconsContainer" ] (viewIcons model) ]

        _ ->
            viewHomeNavigator False :: viewIcons model


viewHeaderText : String -> Html Msg
viewHeaderText txt =
    b [ class "headerItem" ]
        [ text txt ]
