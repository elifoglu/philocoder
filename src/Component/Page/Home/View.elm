module Home.View exposing (..)

import App.Model exposing (IconInfo, Model, Page(..), ReadingMode(..))
import App.Msg exposing (Msg(..))
import Component.Page.Util exposing (tagsLoaded)
import Html exposing (Html, a, br, div, img, input, span, text)
import Html.Attributes exposing (checked, class, href, name, src, style, type_)
import Html.Events exposing (on, onClick)
import Json.Decode as Decode
import Requests exposing (getBioPageIcons, getIcons)
import Tag.Model exposing (Tag)
import TagInfoIcon.View exposing (viewTagInfoIcon)


viewHomePageDiv : List Tag -> List Tag -> ReadingMode -> Html Msg
viewHomePageDiv allTags blogTags readingMode =
    div [ class "homepage homepageTagsFont", style "width" "auto", style "float" "left" ]
        ((tagsToShow readingMode allTags blogTags
            |> List.map (viewTag readingMode)
            |> List.intersperse (br [] [])
         )
            ++ [ br [] [] ]
            ++ viewReadingModeDiv readingMode blogTags
        )


tagNamesToHideOnHomePage : List String
tagNamesToHideOnHomePage =
    [ "beni oku" ]


tagsToShow : ReadingMode -> List Tag -> List Tag -> List Tag
tagsToShow readingMode allTags blogTags =
    let
        tags =
            case readingMode of
                BlogContents ->
                    blogTags

                AllContents ->
                    allTags

        removeTagsToHide =
            tags
                |> List.filter (\tag -> not (List.member tag.name tagNamesToHideOnHomePage))
    in
    removeTagsToHide


tagCountCurrentlyShownOnPage : ReadingMode -> List Tag -> List Tag -> Int
tagCountCurrentlyShownOnPage readingMode allTags blogTags =
    List.length (tagsToShow readingMode allTags blogTags)


viewTag : ReadingMode -> Tag -> Html Msg
viewTag readingMode tag =
    span []
        [ a
            [ class "homepageTagA"
            , href
                ("/tags/"
                    ++ tag.tagId
                    ++ (case readingMode of
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


viewIcons : Model -> List (Html Msg)
viewIcons model =
    case model.activePage of
        BioPage _ ->
            getBioPageIcons True
                |> List.map viewIcon

        _ ->
            (getIcons model.showAdditionalIcons
                |> List.map viewIcon
            )
                ++ (if not model.showAdditionalIcons then
                        [ div [ class "iconDiv" ]
                            [ img [ class "icon showMoreIconsIcon", onClick ShowAdditionalIcons, src "/more.svg" ] []
                            ]
                        ]

                    else
                        []
                   )


viewIcon : IconInfo -> Html Msg
viewIcon iconInfo =
    div [ class "iconDiv" ]
        [ a [ href iconInfo.urlToNavigate ]
            [ img [ class "icon", src iconInfo.iconImageUrl, style "margin-left" iconInfo.marginLeft ] []
            ]
        ]


viewReadingModeDiv : ReadingMode -> List Tag -> List (Html Msg)
viewReadingModeDiv readingMode blogTags =
    if tagsLoaded blogTags then
        --this 'if expression' is just to show this div 'after' tags are shown; not before. it is just about aesthetics
        [ div [ style "margin-top" "5px", style "margin-bottom" "10px", style "margin-left" "-5px" ]
            [ span []
                [ input
                    [ type_ "radio"
                    , name "readingMode"
                    , checked (readingModeCheckFn readingMode)
                    , on "change" (Decode.succeed (ReadingModeChanged BlogContents))
                    ]
                    []
                , text "blog"
                ]
            , span []
                [ input
                    [ type_ "radio"
                    , name "readingMode"
                    , checked (flip (readingModeCheckFn readingMode))
                    , on "change" (Decode.succeed (ReadingModeChanged AllContents))
                    ]
                    []
                , text "tümü"
                ]
            ]
        ]

    else
        []


readingModeCheckFn : ReadingMode -> Bool
readingModeCheckFn readingMode =
    case readingMode of
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
