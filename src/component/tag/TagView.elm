module TagView exposing (viewTagTabs)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import Model exposing (Model)
import Msg exposing (Msg)
import TagModel exposing (Tag)
import TagUtil exposing (contentCountOfTag, nameOfActiveTag)


viewTagTabs : Model -> List (Html Msg)
viewTagTabs model =
    List.map (viewTagTab model) model.allTags


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
