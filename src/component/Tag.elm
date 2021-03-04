module Tag exposing (contentsOfTag, tagById, tagWithMostContents, viewTagTabs)

import Content exposing (Content)
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)
import List exposing (member)
import Model exposing (Model)
import Msg exposing (Msg, Tag)
import Sorter exposing (sortContentsByStrategy)



--UTIL


tagById : List Tag -> String -> Maybe Tag
tagById allTags tagId =
    allTags
        |> List.filter (\tag -> tag.tagId == tagId)
        |> List.head


contentCountOfTag : Model -> Tag -> Int
contentCountOfTag model tag =
    (tag
        |> contentsOfTag model.allContents
    )
        |> List.length


contentsOfTag : List Content -> Tag -> List Content
contentsOfTag allContents tag =
    allContents
        |> List.filter (\content -> member tag content.tags)
        |> sortContentsByStrategy tag.contentSortStrategy


nameOfActiveTag : Model -> String
nameOfActiveTag model =
    case model.activePage of
        Model.TagPage tagId ->
            case tagById model.allTags tagId of
                Just tag ->
                    tag.name

                Nothing ->
                    ""

        _ ->
            ""


tagWithMostContents : Model -> Maybe Tag
tagWithMostContents model =
    model.allTags
        |> List.sortBy (\tag -> contentCountOfTag model tag)
        |> List.reverse
        |> List.head



--VIEW


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
