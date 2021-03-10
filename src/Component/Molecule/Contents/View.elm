module Contents.View exposing (viewContentDivs)

import App.Model exposing (Model)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, div, hr)
import Html.Attributes exposing (style)
import Msg exposing (Msg)
import NotFound.View exposing (view404Div)
import Tag.Model exposing (ContentRenderType(..), Tag)
import Tag.Util exposing (contentsOfTag)


viewContentDivs : Model -> Maybe Tag -> List (Html Msg)
viewContentDivs model maybeTag =
    case maybeTag of
        Just tag ->
            tag
                |> contentsOfTag model.allContents
                |> List.map (viewContentDiv model maybeTag)
                |> List.intersperse (viewContentSeparator tag.contentRenderType)

        Nothing ->
            [ view404Div ]


viewContentSeparator : ContentRenderType -> Html Msg
viewContentSeparator contentRenderType =
    case contentRenderType of
        Normal ->
            div []
                [ hr [] []
                , br [] []
                ]

        Minified ->
            div [ style "margin-bottom" "40px" ]
                []
