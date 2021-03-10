module Tag.Util exposing (contentCountOfTag, contentsOfTag, gotTagToTag, nameOfActiveTag, tagById, tagNameToTag, tagWithMostContents)

import App.Model exposing (Model)
import Content.Model exposing (Content)
import Content.Sorter exposing (sortContentsByStrategy)
import DataResponse exposing (GotTag)
import List exposing (member)
import Tag.Model exposing (Tag)


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
        App.Model.TagPage tagId ->
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


tagNameToTag : List Tag -> String -> Maybe Tag
tagNameToTag allTags tagName =
    allTags
        |> List.filter (\tag -> tag.name == tagName)
        |> List.head


gotTagToTag : GotTag -> Tag
gotTagToTag gotTag =
    gotTag
