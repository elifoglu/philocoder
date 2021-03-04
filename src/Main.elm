port module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Constants exposing (contentApiURL, dataFilename)
import Content exposing (Content, ContentDate(..), ContentText(..))
import ContentUtil exposing (getContentById)
import Date exposing (fromCalendarDate, numberToMonth)
import Http
import List
import Model exposing (..)
import Msg exposing (DataResponse, GotContent, GotContentDate, Msg(..), Tag, tagResponseDecoder)
import TagUtil exposing (getTagById)
import Url
import UrlParser exposing (parseOrHome)
import View exposing (view)


port title : String -> Cmd a


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
    ( Model "empty" key url (parseOrHome url) [] []
    , Http.get
        { url = contentApiURL ++ dataFilename
        , expect = Http.expectJson GotDataResponse tagResponseDecoder
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
                        | allTags = res.allTags
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
                    ( { model | allContents = updateTextOfContents contentId text model.allContents }, sendTitle model (parseOrHome model.currentUrl) )

                Err _ ->
                    ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( addNewLog { model | currentUrl = url } ("internal:" ++ Url.toString url), Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( addNewLog model ("external:" ++ href), Nav.load href )

        UrlChanged url ->
            ( addNewLog { model | activePage = parseOrHome url } ("urlChanged:" ++ Url.toString url)
            , sendTitle model (parseOrHome url)
            )


sendTitle : Model -> Page -> Cmd msg
sendTitle model activePage =
    case activePage of
        HomePage ->
            title "Philocoder"

        ContentPage contentId ->
            case getContentById model.allContents contentId of
                Just content ->
                    title (content.title ++ " - Philocoder")

                Nothing ->
                    Cmd.none

        TagPage tagId ->
            case getTagById model.allTags tagId of
                Just tag ->
                    title (tag.name ++ " - Philocoder")

                Nothing ->
                    Cmd.none

        NotFoundPage ->
            title "Oops - Not Found"


addNewLog : Model -> String -> Model
addNewLog model str =
    { model | log = model.log ++ "-----" ++ str }



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
    { tagId = "DUMMY", name = "DUMMY", contentSortStrategy = "DUMMY", showAsTag = False }


view =
    View.view


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
