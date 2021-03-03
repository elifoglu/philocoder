module View exposing (view)

import Browser exposing (Document)
import Content exposing (Content)
import ContentUtil exposing (getContentById, getDateTextOfContent, getTagsTextOfContent, getTextOfContent)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import Markdown
import Model as M exposing (..)
import Msg exposing (Msg(..), Tag)
import TagUtil exposing (contentCountOfTag, getContentsOfTag, getTagById, nameOfActiveTag, tagWithMostContents)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            ([ css "../style.css", homeNavigator ]
                ++ tagTabs model
                ++ [ case model.activePage of
                        M.HomePage ->
                            viewContentsOfTagDiv model.allContents (tagWithMostContents model)

                        M.ContentPage contentId ->
                            maybeContentDiv model.allContents contentId

                        M.TagPage tagId ->
                            viewContentsOfTagDiv model.allContents (getTagById model.allTags tagId)

                   --todo implement mtagpage view
                   ]
            )
        ]

    --todo yamuk yumuk oldu, düzelt
    {- [ text "The current URL is: "
       , b [] [ text (Url.toString model.currentUrl) ]
       , hr [] []
       , viewContentLink 5
       , hr [] []
       , text model.log
       ]
    -}
    }


viewContentLink : Int -> Html msg
viewContentLink contentId =
    a [ href ("/contents/" ++ String.fromInt contentId) ]
        [ img [ class "navToContent", src "../content/link.svg" ] []
        ]


tagTabs : Model -> List (Html Msg)
tagTabs model =
    List.map (tagTab model) model.allTags


homeNavigator : Html Msg
homeNavigator =
    a [ class "homeLink", href "/" ]
        [ b [ style "font-weight" "bolder" ]
            [ text "philocoder" ]
        ]


tagTab : Model -> Tag -> Html Msg
tagTab model tag =
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


viewContentsOfTagDiv : List Content -> Maybe Tag -> Html Msg
viewContentsOfTagDiv allContents maybeTag =
    div [ class "contents" ]
        (case maybeTag of
            Just tag ->
                tag
                    |> getContentsOfTag allContents
                    |> List.map contentDiv

            Nothing ->
                []
        )


maybeContentDiv : List Content -> Int -> Html Msg
maybeContentDiv allContents contentId =
    case getContentById allContents contentId of
        Just content ->
            contentDiv content

        Nothing ->
            div [] []


contentDiv : Content -> Html Msg
contentDiv content =
    div [ class "contents" ]
        [ p [ style "margin-bottom" "30px" ]
            [ span [ class "title" ] [ text (content.title ++ " "), viewContentLink content.contentId ]
            , br [] []
            , getTagsTextOfContent content
            , getDateTextOfContent content
            ]
        , div [ style "max-width" "600px" ]
            [ Markdown.toHtml [] (getTextOfContent content)
            , br [] []
            , hr [] []
            , br [] []
            ]
        ]


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
