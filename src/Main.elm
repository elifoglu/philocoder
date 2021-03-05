module Main exposing (main)

import AppModel exposing (..)
import AppView exposing (..)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Content.Util exposing (gotContentToContent, updateTextOfContents)
import DataResponse exposing (DataResponse, GotContent, GotContentDate, GotTag)
import List
import Msg exposing (Msg(..))
import Ports exposing (sendTitle)
import Requests exposing (getContentText, getDataResponse)
import Tag.Util exposing (gotTagToTag)
import Url
import UrlParser exposing (pageBy)


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
    , getDataResponse
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
                    , Cmd.batch (List.map getContentText allContents)
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
