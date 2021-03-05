module Content.Util exposing (contentById, gotContentToContent, updateTextOfContents)

import Content.Model exposing (Content, ContentDate(..), ContentText(..))
import DataResponse exposing (GotContent, GotContentDate, GotTag)
import Date exposing (fromCalendarDate, numberToMonth)
import Maybe.Extra exposing (values)
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
    , text = NotRequestedYet
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


updateTextOfContents : Int -> String -> List Content -> List Content
updateTextOfContents contentId text contents =
    contents
        |> List.map (updateTextOfContent contentId text)


updateTextOfContent : Int -> String -> Content -> Content
updateTextOfContent contentId text content =
    if content.contentId == contentId then
        { content | text = Text text }

    else
        content
