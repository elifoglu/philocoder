module Main exposing (main)

import AppModel exposing (..)
import AppView exposing (..)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Constants exposing (contentApiURL, dataFilename)
import Content.Model exposing (..)
import DataResponse exposing (DataResponse, GotContent, GotContentDate, GotTag, dataResponseDecoder)
import Date exposing (fromCalendarDate, numberToMonth)
import Http
import List
import Msg exposing (Msg(..))
import Ports exposing (sendTitle)
import Tag.Model exposing (Tag)
import Url
import UrlParser exposing (pageBy)



--todo make codebase modular by doing a refactor


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model "log" key (pageBy url) [] []
    , Http.get
        { url = contentApiURL ++ dataFilename
        , expect = Http.expectJson GotDataResponse dataResponseDecoder
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --todo no 2) 1 numaralı todo yapıldıktan sonra, burada da aktif tag için cmd gönderilmeli
        GotDataResponse tagsResult ->
            case tagsResult of
                Ok res ->
                    let
                        allContents =
                            List.map (gotContentToContent res.allTags) res.allContents
                    in
                    ( { model
                        | allTags = List.map gotTagToTag res.allTags
                        , allContents = allContents
                      }
                    , Cmd.batch (List.map toHttpReq allContents)
                      --todo no 1) sadece aktif tag'in content'leri için request atılmalı
                    )

                Err _ ->
                    ( model, Cmd.none )

        GotContentText contentId contentTextResult ->
            case contentTextResult of
                Ok text ->
                    ( { model | allContents = updateTextOfContents contentId text model.allContents }, sendTitle model )

                Err _ ->
                    ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newModel : Model
                newModel =
                    { model | activePage = pageBy url }
            in
            ( newModel
            , sendTitle newModel
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


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


gotContentToContent : List GotTag -> GotContent -> Content
gotContentToContent allTags gotContent =
    { title = gotContent.title
    , date = gotContentDateToContentDate gotContent.date
    , contentId = gotContent.contentId
    , text = NotRequestedYet
    , tags = List.filter (\tag -> tag /= dummyTag) (List.map (tagNameToTag allTags) gotContent.tags)
    , refs = gotContent.refs
    }


gotTagToTag : GotTag -> Tag
gotTagToTag gotTag =
    gotTag


gotContentDateToContentDate : GotContentDate -> ContentDate
gotContentDateToContentDate gotContentDate =
    case gotContentDate of
        DataResponse.DateExists dateAndPublishOrder ->
            DateExists (fromCalendarDate dateAndPublishOrder.year (numberToMonth dateAndPublishOrder.month) dateAndPublishOrder.day) dateAndPublishOrder.publishOrderInDay

        DataResponse.DateNotExists justPublishOrder ->
            DateNotExists justPublishOrder.publishOrderInDay


tagNameToTag : List Tag -> String -> Tag
tagNameToTag allTags tagName =
    Maybe.withDefault dummyTag (List.head (List.filter (\tag -> tag.name == tagName) allTags))


dummyTag : Tag
dummyTag =
    { tagId = "DUMMY", name = "DUMMY", contentSortStrategy = "DUMMY", showAsTag = False }



--todo remove dummy tag related things
