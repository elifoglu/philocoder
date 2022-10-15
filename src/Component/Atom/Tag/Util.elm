module Tag.Util exposing (gotTagToTag, tagById, tagNameToTag)

import DataResponse exposing (GotTag)
import List
import Tag.Model exposing (ContentRenderType, Tag)


tagById : List Tag -> String -> Maybe Tag
tagById allTags tagId =
    allTags
        |> List.filter (\tag -> tag.tagId == tagId)
        |> List.head


tagNameToTag : List Tag -> String -> Maybe Tag
tagNameToTag allTags tagName =
    allTags
        |> List.filter (\tag -> tag.name == tagName)
        |> List.head


gotTagToTag : GotTag -> Tag
gotTagToTag gotTag =
    gotTag