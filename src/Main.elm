port module Main exposing (..)

import ApiUtil exposing (contentApiURL, dataFilename)
import Browser
import Content exposing (Content, ContentDate(..), ContentText(..))
import Date exposing (fromCalendarDate, numberToMonth)
import Http
import List
import Model exposing (..)
import Msg exposing (DataResponse, GotContent, GotContentDate, Msg(..), Tag, tagResponseDecoder)
import View exposing (view)


port title : String -> Cmd a


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { activeTag = Nothing, allTags = [], allContents = [] }
    , Http.get
        { url = contentApiURL ++ dataFilename
        , expect = Http.expectJson GotDataResponse tagResponseDecoder
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TagSelected tag ->
            ( { model | activeTag = Just tag }, Cmd.none )

        --todo 2) 1 numaralı todo yapıldıktan sonra, burada da aktif tag için cmd gönderilmeli
        GotDataResponse tagsResult ->
            case tagsResult of
                Ok res ->
                    let
                        allContents =
                            List.map (gotContentToContent res.allTags) res.allContents
                    in
                    ( { activeTag = getActiveTag res.nameOfActiveTag res.allTags
                      , allTags = res.allTags
                      , allContents = allContents
                      }
                    , Cmd.batch (List.map toHttpReq allContents)
                      --todo 1) sadece aktif tag'in content'leri için request atılmalı
                    )

                Err _ ->
                    ( model, Cmd.none )

        GotContentText contentId contentTextResult ->
            case contentTextResult of
                Ok text ->
                    ( { model | allContents = updateTextOfContents contentId text model.allContents }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



--todo make codebase modular by doing a refactor


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


toHttpReq : Content -> Cmd Msg
toHttpReq content =
    Http.get
        { url = contentApiURL ++ String.fromInt content.contentId
        , expect = Http.expectString (GotContentText content.contentId)
        }


gotContentToContent : List Tag -> GotContent -> Content
gotContentToContent allTags gotContent =
    { title = gotContent.title
    , date = gotContentDateToContentDate gotContent.date
    , contentId = gotContent.contentId
    , text = NotRequestedYet
    , tags = List.filter (\tag -> tag /= dummyTag) (List.map (tagNameToTag allTags) gotContent.tags)
    }


gotContentDateToContentDate : GotContentDate -> ContentDate
gotContentDateToContentDate gotContentDate =
    case gotContentDate of
        Msg.DateExists dateAndPublishOrder ->
            DateExists (fromCalendarDate dateAndPublishOrder.year (numberToMonth dateAndPublishOrder.month) dateAndPublishOrder.day) dateAndPublishOrder.publishOrderInDay

        Msg.DateNotExists justPublishOrder ->
            DateNotExists justPublishOrder.publishOrderInDay


tagNameToTag : List Tag -> String -> Tag
tagNameToTag allTags tagName =
    Maybe.withDefault dummyTag (List.head (List.filter (\tag -> tag.name == tagName) allTags))


dummyTag : Tag
dummyTag =
    { name = "DUMMY", contentSortStrategy = "DUMMY", showAsTag = False }


getActiveTag : String -> List Tag -> Maybe Tag
getActiveTag nameOfActiveTag allTags =
    List.head (List.filter (tagIsActive nameOfActiveTag) allTags)


tagIsActive : String -> Tag -> Bool
tagIsActive activeTagName tag =
    tag.name == activeTagName


view =
    View.view


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
