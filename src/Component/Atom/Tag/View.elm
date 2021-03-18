module Tag.View exposing (viewTagTab)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
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
            [ class "tagLinkInHeader"
            , href ("/tags/" ++ tag.tagId)
            ]
            [ text
                (tag.name
                    ++ (if tag.showContentCount then
                            " (" ++ String.fromInt (contentCountOfTag model tag) ++ ")"

                        else
                            ""
                       )
                )
            ]
        ]
