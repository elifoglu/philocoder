module Home.View exposing (..)

import App.Model exposing (IconInfo, Model, Page(..), ReadingMode(..))
import App.Msg exposing (Msg(..))
import Html exposing (Html, a, br, button, div, img, input, span, text)
import Html.Attributes exposing (checked, class, href, name, placeholder, src, style, type_, value)
import Html.Events exposing (on, onCheck, onClick, onInput)
import Json.Decode as Decode
import Requests exposing (getBioPageIcons, getIcons)
import Tag.Model exposing (Tag)
import TagInfoIcon.View exposing (viewTagInfoIcon)


viewHomePageDiv : Maybe (List Tag) -> Maybe (List Tag) -> ReadingMode -> Bool -> Bool -> Html Msg
viewHomePageDiv allTagsToShow blogTagsToShow readingMode loggedIn consumeModeIsOn =
    div [ class "homepage homepageTagsFont", style "width" "auto", style "float" "left" ]
        ((tagsToShow readingMode allTagsToShow blogTagsToShow
            |> List.map (viewTag readingMode)
            |> List.intersperse (br [] [])
         )
            ++ [ showAllContentsAreReadMessageIfNecessary allTagsToShow blogTagsToShow readingMode ]
            ++ [ br [] [] ]
            ++ viewMiscDiv readingMode blogTagsToShow loggedIn consumeModeIsOn
        )


tagNamesToHideOnHomePage : List String
tagNamesToHideOnHomePage =
    [ "beni oku" ]


tagsToShow : ReadingMode -> Maybe (List Tag) -> Maybe (List Tag) -> List Tag
tagsToShow readingMode allTagsToShow blogTagsToShow =
    let
        maybeTags =
            case readingMode of
                BlogContents ->
                    blogTagsToShow

                AllContents ->
                    allTagsToShow

        tags =
            Maybe.withDefault [] maybeTags

        --this will never happen
        removeTagsToHide =
            tags
                |> List.filter (\tag -> not (List.member tag.name tagNamesToHideOnHomePage))
    in
    removeTagsToHide


tagCountCurrentlyShownOnPage : ReadingMode -> Maybe (List Tag) -> Maybe (List Tag) -> Int
tagCountCurrentlyShownOnPage readingMode allTags blogTags =
    let
        tagsCount =
            List.length (tagsToShow readingMode allTags blogTags)
    in
    if tagsCount == 0 then
        1

    else
        tagsCount



-- if all contents are read, we show an info message to user about it and its height is exactly one-tag-view-long. so, this is just a correction for "user read all blog/all contents" case


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


showAllContentsAreReadMessageIfNecessary : Maybe (List Tag) -> Maybe (List Tag) -> ReadingMode -> Html Msg
showAllContentsAreReadMessageIfNecessary allTagsToShow blogTagsToShow readingMode =
    let
        maybeTags =
            case readingMode of
                BlogContents ->
                    blogTagsToShow

                AllContents ->
                    allTagsToShow

        infoMessage =
            case maybeTags of
                Just [] ->
                    span [] [ text "buradaki tüm içerikleri okudunuz" ]

                _ ->
                    text ""
    in
    infoMessage


viewIconsDiv : Model -> Html Msg
viewIconsDiv model =
    case model.activePage of
        BioPage _ ->
            div [ class "bioPageIconsContainer" ]
                (getBioPageIcons True
                    |> List.map viewIcon
                )

        _ ->
            div [ class "iconsContainer" ]
                ((getIcons model.showAdditionalIcons
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
                )


viewIcon : IconInfo -> Html Msg
viewIcon iconInfo =
    div [ class "iconDiv" ]
        [ a [ href iconInfo.urlToNavigate ]
            [ img [ class "icon", src iconInfo.iconImageUrl, style "margin-left" iconInfo.marginLeft ] []
            ]
        ]


viewMiscDiv : ReadingMode -> Maybe (List Tag) -> Bool -> Bool -> List (Html Msg)
viewMiscDiv readingMode blogTagsToShow loggedIn consumeModeIsOn =
    if blogTagsToShow /= Nothing then
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
            , input [ type_ "text", class "contentSearchInput", placeholder "ara...", value "", onInput GotSearchInput, style "margin-left" "5px" ] []
            , if not loggedIn then
                text ""

              else
                span []
                    [ input [ type_ "checkbox", class "consumeModeToggle", checked consumeModeIsOn, onCheck ConsumeModeChanged ] []
                    ]
            , if not loggedIn then
                text ""

              else
                logoutButton Logout
            ]
        ]

    else
        []


logoutButton : msg -> Html msg
logoutButton msg =
    button [ onClick msg, class "logoutButton" ] [ text "çık" ]


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
