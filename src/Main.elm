module Main exposing (main)

import App.Model exposing (..)
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Content.Util exposing (gotContentToContent, updateTextOfContents)
import DataResponse exposing (DataResponse, GotContent, GotContentDate, GotTag)
import List
import Msg exposing (Msg(..))
import Requests exposing (getContentText, getDataResponse)
import Tag.Util exposing (gotTagToTag)
import Url


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
                      --todo no 1) just send commands for active tag's contents. not for all contents
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

        --todo no 2) if todo1 is done, a new command should be sent (if not sent before) after every tag click
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
