module Tag.Util exposing (contentRenderTypeOf, contentSortStrategyOf, gotTagToTag, nameOfActiveTag, tagById, tagNameToTag, tagWithMostContents)

import App.Model exposing (Model)
import DataResponse exposing (GotTag)
import List
import Tag.Model as ContentRenderType exposing (ContentRenderType, Tag)


tagById : List Tag -> String -> Maybe Tag
tagById allTags tagId =
    allTags
        |> List.filter (\tag -> tag.tagId == tagId)
        |> List.head


nameOfActiveTag : Model -> String
nameOfActiveTag model =
    case model.activePage of
        App.Model.TagPage tag _ _ ->
            tag.name

        _ ->
            ""


tagWithMostContents : Model -> Maybe Tag
tagWithMostContents model =
    model.allTags
        |> List.sortBy (\tag -> tag.contentCount)
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


contentSortStrategyOf : Maybe Tag -> String
contentSortStrategyOf maybeTag =
    case maybeTag of
        Just tag ->
            tag.contentSortStrategy

        Nothing ->
            "DateDESC"


contentRenderTypeOf : Maybe Tag -> ContentRenderType
contentRenderTypeOf maybeTag =
    case maybeTag of
        Just tag ->
            tag.contentRenderType

        Nothing ->
            ContentRenderType.Normal
