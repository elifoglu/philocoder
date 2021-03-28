module Content.Util exposing (contentById, gotContentToContent, maybeDateText, maybeDisplayableTagsOfContent)

import Content.Model exposing (Content, ContentDate(..))
import DataResponse exposing (GotContent, GotContentDate, GotTag)
import Date exposing (format, fromCalendarDate, numberToMonth)
import Maybe.Extra exposing (values)
import Tag.Model exposing (Tag)
import Tag.Util exposing (tagNameToTag)


contentById : List Content -> Int -> Maybe Content
contentById contents id =
    contents
        |> List.filter (\a -> a.contentId == id)
        |> List.head


gotContentToContent : List GotTag -> GotContent -> Content
gotContentToContent allTags gotContent =
    { title = gotContent.title
    , date = gotContentDateToContentDate gotContent.date
    , contentId = gotContent.contentId
    , text = gotContent.content
    , tags =
        gotContent.tags
            |> List.map (tagNameToTag allTags)
            |> values
    , refs = gotContent.refs
    }


gotContentDateToContentDate : GotContentDate -> ContentDate
gotContentDateToContentDate gotContentDate =
    case gotContentDate of
        DataResponse.DateExists dateAndPublishOrder ->
            DateExists (fromCalendarDate dateAndPublishOrder.year (numberToMonth dateAndPublishOrder.month) dateAndPublishOrder.day) dateAndPublishOrder.publishOrderInDay

        DataResponse.DateNotExists justPublishOrder ->
            DateNotExists justPublishOrder.publishOrderInDay


contentHasDisplayableTags : Content -> Bool
contentHasDisplayableTags content =
    (content.tags
        |> List.filter (\tag -> tag.showAsTag)
        |> List.length
    )
        > 0


maybeDisplayableTagsOfContent : Content -> Maybe (List Tag)
maybeDisplayableTagsOfContent content =
    case contentHasDisplayableTags content of
        True ->
            Just
                (content.tags
                    |> List.filter (\tag -> tag.showAsTag)
                )

        False ->
            Nothing


maybeDateText : Content -> Maybe String
maybeDateText content =
    let
        dateText =
            case content.date of
                DateExists date _ ->
                    format "dd.MM.yy" date

                DateNotExists _ ->
                    ""
    in
    if String.isEmpty dateText then
        Nothing

    else
        Just dateText
