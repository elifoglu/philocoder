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
        ((tagsToShow model
            |> List.map (viewTag model.readingMode)
            |> List.intersperse (br [] [])
         )
            ++ [ br [] [] ]
            ++ viewBioHref model
            ++ [ br [] [] ]
            ++ viewReadingModeDiv model
            ++ viewIconsDiv model
        )


tagsToShow : Model -> List Tag
tagsToShow model =
    case model.readingMode of
        NotSelectedYet ->
            model.blogModeTags

        BlogContents ->
            model.blogModeTags

        AllContents ->
            model.allTags


tagToBeBold =
    --todo "make 'beni_oku.txt' bold" action should be done in a more clear way
    "beni oku"


viewTag : ReadingMode -> Tag -> Html Msg
viewTag readingMode tag =
    span []
        [ a
            [ class "homepageTagA"
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
            (if tag.showContentCount then
                [ text tag.name
                , span [ class "contentCountOfTag" ] [ text (" (" ++ String.fromInt tag.contentCount ++ ")") ]
                ]

             else
                [ text tag.name ]
            )
        , text " "
        , viewTagInfoIcon tag
        ]


areTagsLoaded : Model -> Bool
areTagsLoaded model =
    model.allTags /= []


viewBioHref : Model -> List (Html Msg)
viewBioHref model =
    if areTagsLoaded model then
        [ a [ class "bioHrefAtHomePage homepageTagA", href "/me" ] [ text "kim bu" ] ]

    else
        []


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
    a [ class "iconA", href iconInfo.urlToNavigate ]
        [ img [ class "icon", src iconInfo.iconImageUrl, style "margin-right" iconInfo.marginRight ] []
        ]


viewReadingModeDiv : Model -> List (Html Msg)
viewReadingModeDiv model =
    if areTagsLoaded model then
        --this 'if expression' is just to show icons 'after' tags are shown; not before. it is just about aesthetics
        [ div [ style "margin-top" "5px", style "margin-bottom" "10px", style "margin-left" "-5px" ]
            [ span []
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
                    , checked (flip (readingModeCheckFn model))
                    , on "change" (Decode.succeed (ReadingModeChanged AllContents))
                    ]
                    []
                , text "tümü"
                ]
            ]
        ]

    else
        []


readingModeCheckFn : Model -> Bool
readingModeCheckFn model =
    case model.readingMode of
        NotSelectedYet ->
            True

        BlogContents ->
            True

        AllContents ->
            False


flip : Bool -> Bool
flip bool =
    if bool == True then
        False

    else
        True
