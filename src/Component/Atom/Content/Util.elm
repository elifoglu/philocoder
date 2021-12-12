module Content.Util exposing (contentById, gotContentToContent, maybeDateText, maybeDisplayableTagsOfContent)

import App.Model exposing (Model)
import Content.Model exposing (Content, ContentDate)
import DataResponse exposing (GotContent, GotContentDate, GotTag)
import Date exposing (format)
import Maybe.Extra exposing (values)
import Tag.Model exposing (Tag)
import Tag.Util exposing (tagNameToTag)
import Time


contentById : List Content -> Int -> Maybe Content
contentById contents id =
    contents
        |> List.filter (\a -> a.contentId == id)
        |> List.head


gotContentToContent : Model -> GotContent -> Content
gotContentToContent model gotContent =
    { title = gotContent.title
    , date = gotContentDateToContentDate model.timeZone gotContent.dateAsTimestamp
    , contentId = gotContent.contentId
    , text = gotContent.content
    , tags =
        gotContent.tags
            |> List.map (tagNameToTag model.allTags)
            |> values
    , refs = gotContent.refs
    , okForBlogMode = gotContent.okForBlogMode
    }


jan2000 =
    946688437314


gotContentDateToContentDate : Time.Zone -> GotContentDate -> ContentDate
gotContentDateToContentDate timeZone gotContentDate =
    case String.toInt gotContentDate of
        Just ms ->
            Date.fromPosix timeZone (Time.millisToPosix ms)

        Nothing ->
            Date.fromPosix timeZone (Time.millisToPosix jan2000)


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
        dateText : String
        dateText =
            format "dd.MM.yy" content.date
    in
    if String.isEmpty dateText then
        --will be updated
        Just "sase"

    else
        Just dateText
