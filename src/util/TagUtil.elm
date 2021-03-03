module TagUtil exposing (..)

import Content exposing (Content)
import List exposing (member)
import Model exposing (Model)
import Msg exposing (Tag)
import SortUtil exposing (sortContentsByStrategy)


contentCountOfTag : Model -> Tag -> Int
contentCountOfTag model tag =
    (tag
        |> getContentsOfTag model.allContents
    )
        |> List.length


getContentsOfTag : List Content -> Tag -> List Content
getContentsOfTag allContents tag =
    allContents
        |> List.filter (\content -> member tag content.tags)
        |> sortContentsByStrategy tag.contentSortStrategy


nameOfActiveTag : Model -> String
nameOfActiveTag model =
    case model.activePage of
        Model.TagPage tagId ->
            case getTagById model.allTags tagId of
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


getTagById : List Tag -> String -> Maybe Tag
getTagById allTags tagId =
    allTags
        |> List.filter (\tag -> tag.tagId == tagId)
        |> List.head
