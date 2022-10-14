module Tag.Util exposing (contentRenderTypeOf, gotTagToTag, nameOfActiveTag, tagById, tagNameToTag, tagWithMostContents)

import App.Model exposing (Initializable(..), Model, Page(..))
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
        TagPage status ->
            case status of
                Initialized initialized ->
                    initialized.tag.name

                _ ->
                    ""

        _ ->
            ""


tagWithMostContents : List Tag -> Model -> Maybe Tag
tagWithMostContents allTags model =
    allTags
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


contentRenderTypeOf : Maybe Tag -> ContentRenderType
contentRenderTypeOf maybeTag =
    case maybeTag of
        Just tag ->
            tag.contentRenderType

        Nothing ->
            ContentRenderType.Normal
