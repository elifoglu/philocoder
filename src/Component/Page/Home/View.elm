module Home.View exposing (..)

import App.Model exposing (IconInfo, Model)
import App.Msg exposing (Msg)
import Html exposing (Html, a, br, div, img, span, text)
import Html.Attributes exposing (class, href, src, style)
import Tag.Model exposing (Tag)
import TagInfoIcon.View exposing (viewTagInfoIcon)


viewHomePageDiv : Model -> Html Msg
viewHomePageDiv model =
    div [ style "width" "auto", style "float" "left" ]
        ((model.allTags
            |> List.map viewTag
            |> List.intersperse (br [] [])
         )
            ++ [ br [] [], br [] [] ]
            ++ viewIconsDiv model
        )


tagToBeBold =
    --todo "make 'beni_oku.txt' bold" action should be done in a more clear way
    "beni_oku.txt"


viewTag : Tag -> Html Msg
viewTag tag =
    span []
        [ a
            [ style "text-decoration" "none"
            , style "font-weight"
                (if tag.name /= tagToBeBold then
                    "normal"

                 else
                    "bold"
                )
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


viewIconsDiv : Model -> List (Html Msg)
viewIconsDiv model =
    model.icons
        |> List.map viewIcon


viewIcon : IconInfo -> Html Msg
viewIcon iconInfo =
    a [ href iconInfo.urlToNavigate ]
        [ img [ class "icon", src iconInfo.iconImageUrl, style "margin-right" iconInfo.marginRight ] []
        ]
