module Content.Util exposing (gotContentToContent, maybeDateText, maybeDisplayableTagsOfContent, textOnlyContent)

import App.Model exposing (Model)
import Content.Model exposing (Content, ContentDate, GraphData)
import DataResponse exposing (ContentID, GotContent, GotContentDate, GotTag)
import Date exposing (format)
import Maybe.Extra exposing (values)
import Tag.Model exposing (Tag)
import Tag.Util exposing (tagNameToTag)
import Time


gotContentToContent : Model -> GotContent -> Content
gotContentToContent model gotContent =
    { title = gotContent.title
    , date = gotContentDateToContentDate model.timeZone gotContent.dateAsTimestamp
    , contentId = gotContent.contentId
    , text = gotContent.content
    , beautifiedText = gotContent.beautifiedContentText
    , tags =
        gotContent.tags
            |> List.map (tagNameToTag model.allTags)
            |> values
    , refs = gotContent.refs
    , okForBlogMode = gotContent.okForBlogMode
    , isContentRead = gotContent.isContentRead
    , furtherReadingRefs = gotContent.furtherReadingRefs
    , gotGraphData = gotContent.graphData
    , graphDataIfGraphIsOn = Nothing
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
        |> List.filter (\tag -> tag.showInTagsOfContent)
        |> List.length
    )
        > 0


maybeDisplayableTagsOfContent : Content -> Maybe (List Tag)
maybeDisplayableTagsOfContent content =
    case contentHasDisplayableTags content of
        True ->
            Just
                (content.tags
                    |> List.filter (\tag -> tag.showInTagsOfContent)
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
    Just dateText


textOnlyContent : ContentID -> Bool
textOnlyContent contentId =
    let
        textOnlyContentIds =
            [ 10000, 10001 ]
    in
    List.member contentId textOnlyContentIds
