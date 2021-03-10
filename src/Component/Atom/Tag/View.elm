module Tag.View exposing (viewTagTab)

import App.Model exposing (Model)
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import Msg exposing (Msg)
import Tag.Model exposing (Tag)
import Tag.Util exposing (contentCountOfTag, nameOfActiveTag)


viewTagTab : Model -> Tag -> Html Msg
viewTagTab model tag =
    div
        [ class
            (if tag.name == nameOfActiveTag model then
                "tagTab tagTabActive"

             else
                "tagTab"
            )
        ]
        [ a
            [ class "tagLink"
            , href ("/tags/" ++ tag.tagId)
            ]
            [ text (tag.name ++ " (" ++ String.fromInt (contentCountOfTag model tag) ++ ")") ]
        ]
