module Home.View exposing (..)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import Html exposing (Html, a, br, div, span, text)
import Html.Attributes exposing (href, style)
import Tag.Model exposing (Tag)
import TagInfoIcon.View exposing (viewTagInfoIcon)


viewHomePageDiv : Model -> Html Msg
viewHomePageDiv model =
    div [] <|
        (model.allTags
            |> List.map viewTag
            |> List.intersperse (br [] [])
        )


viewTag : Tag -> Html Msg
viewTag tag =
    span []
        [ a
            [ style "text-decoration" "none"
            , href ("/tags/" ++ tag.tagId)
            ]
            [ text
                (tag.name
                    ++ (if tag.showContentCount then
                            " (" ++ String.fromInt tag.contentCount ++ ")"

                        else
                            ""
                       )
                )
            ]
        , text " "
        , viewTagInfoIcon tag
        ]
