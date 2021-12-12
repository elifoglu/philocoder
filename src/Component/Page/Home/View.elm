module Home.View exposing (..)

import App.Model exposing (IconInfo, Model, ReadingMode(..))
import App.Msg exposing (Msg(..))
import Html exposing (Html, a, br, div, img, input, span, text)
import Html.Attributes exposing (checked, class, href, name, src, style, type_)
import Html.Events exposing (on)
import Json.Decode as Decode
import Tag.Model exposing (Tag)
import TagInfoIcon.View exposing (viewTagInfoIcon)


viewHomePageDiv : Model -> Html Msg
viewHomePageDiv model =
    div [ class "homepageTagsFont", style "width" "auto", style "float" "left" ]
        (viewReadingModeDiv model
            ++ [ br [] [], br [] [] ]
            ++ (model.allTags
                    |> List.map (viewTag model.readingMode)
                    |> List.intersperse (br [] [])
               )
            ++ [ br [] [], br [] [] ]
            ++ viewIconsDiv model
        )


tagToBeBold =
    --todo "make 'beni_oku.txt' bold" action should be done in a more clear way
    "beni_oku.txt"


viewTag : ReadingMode -> Tag -> Html Msg
viewTag readingMode tag =
    span []
        [ a
            [ style "text-decoration" "none"
            , style "font-weight"
                (if tag.name /= tagToBeBold then
                    "normal"

                 else
                    "bold"
                )
            , href
                ("/tags/"
                    ++ tag.tagId
                    ++ (case readingMode of
                            NotSelectedYet ->
                                "?mode=blog"

                            BlogContents ->
                                "?mode=blog"

                            AllContents ->
                                ""
                       )
                )
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


areTagsLoaded : Model -> Bool
areTagsLoaded model =
    model.allTags /= []


viewIconsDiv : Model -> List (Html Msg)
viewIconsDiv model =
    if areTagsLoaded model then
        --this 'if expression' is just to show icons 'after' tags are shown; not before. it is just about aesthetics
        model.icons
            |> List.map viewIcon

    else
        []


viewIcon : IconInfo -> Html Msg
viewIcon iconInfo =
    a [ href iconInfo.urlToNavigate ]
        [ img [ class "icon", src iconInfo.iconImageUrl, style "margin-right" iconInfo.marginRight ] []
        ]


viewReadingModeDiv : Model -> List (Html Msg)
viewReadingModeDiv model =
    [ text "mod:"
    , span []
        [ input
            [ type_ "radio"
            , name "readingMode"
            , checked (readingModeCheckFn model)
            , on "change" (Decode.succeed (ReadingModeChanged BlogContents))
            ]
            []
        , text "blog"
        ]
    , span []
        [ input
            [ type_ "radio"
            , name "readingMode"
            , on "change" (Decode.succeed (ReadingModeChanged AllContents))
            ]
            []
        , text "tümü"
        ]
    ]


readingModeCheckFn : Model -> Bool
readingModeCheckFn model =
    case model.readingMode of
        NotSelectedYet ->
            True

        BlogContents ->
            True

        AllContents ->
            False
