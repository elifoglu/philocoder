module TagUtil exposing (contentCountOfTag, contentsOfTag, nameOfActiveTag, tagById, tagWithMostContents)

import ContentModel exposing (Content)
import List exposing (member)
import Model exposing (Model)
import Sorter exposing (sortContentsByStrategy)
import TagModel exposing (Tag)


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
