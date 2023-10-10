module TagInfoIcon.View exposing (viewTagInfoIcon)

import App.IconUtil exposing (getIconPath)
import App.Model exposing (Theme)
import App.Msg exposing (Msg)
import Html exposing (Html, a, img, text)
import Html.Attributes exposing (class, href, src, style)
import Tag.Model exposing (Tag)


viewTagInfoIcon : Theme -> Tag -> Html Msg
viewTagInfoIcon activeTheme tag =
    case tag.infoContentId of
        Just contentId ->
            a
                [ href ("/contents/" ++ String.fromInt contentId)
                ]
                [ img [ class "navToTagDesc", src (getIconPath activeTheme "info") ] []
                ]

        Nothing ->
            text ""
