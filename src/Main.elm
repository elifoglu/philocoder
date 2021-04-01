module Main exposing (main)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Content.Util exposing (gotContentToContent)
import List
import Pagination.Model exposing (Pagination)
import Requests exposing (getAllTags, getContent, getHomeContents, getTagContents)
import Tag.Util exposing (gotTagToTag, tagById)
import Url


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model "log" key (pageBy url) []
    , getAllTags
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAllTags res ->
            case res of
                Ok gotTags ->
                    let
                        allTags =
                            List.map gotTagToTag gotTags
                    in
                    ( { model
                        | allTags = allTags
                      }
                    , case model.activePage of
                        NonInitializedHomePage ->
                            getHomeContents

                        NonInitializedContentPage contentId ->
                            getContent contentId

                        NonInitializedTagPage tagId maybePage ->
                            case tagById allTags tagId of
                                Just tag ->
                                    getTagContents tag maybePage

                                Nothing ->
                                    Cmd.none

                        _ ->
                            Cmd.none
                    )

                Err _ ->
                    ( { model
                        | activePage = MaintenancePage
                      }
                    , Cmd.none
                    )

        GotContent result ->
            case result of
                Ok gotContent ->
                    let
                        content =
                            gotContentToContent model.allTags gotContent

                        newModel =
                            { model
                                | activePage = ContentPage content
                            }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

                Err _ ->
                    let
                        newModel =
                            { model | activePage = NotFoundPage }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

        GotContentsOfTag tag result ->
            case result of
                Ok contentsResponse ->
                    let
                        currentPage =
                            case model.activePage of
                                NonInitializedTagPage _ maybePage ->
                                    Maybe.withDefault 1 maybePage

                                _ ->
                                    1

                        pagination =
                            Pagination currentPage contentsResponse.totalPageCount

                        newModel =
                            { model
                                | activePage = TagPage tag (List.map (gotContentToContent model.allTags) contentsResponse.contents) pagination
                            }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

                Err _ ->
                    ( model, Cmd.none )

        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        UrlChanged url ->
            let
                activePage : Page
                activePage =
                    pageBy url

                newModel : Model
                newModel =
                    { model | activePage = activePage }
            in
            ( newModel
            , Cmd.batch
                [ sendTitle newModel
                , case activePage of
                    NonInitializedHomePage ->
                        getHomeContents

                    NonInitializedContentPage contentId ->
                        getContent contentId

                    NonInitializedTagPage tagId maybePage ->
                        case tagById model.allTags tagId of
                            Just tag ->
                                getTagContents tag maybePage

                            Nothing ->
                                Cmd.none

                    _ ->
                        Cmd.none
                ]
            )

        GotHomeContents result ->
            case result of
                Ok contentsResponse ->
                    let
                        newModel =
                            { model
                                | activePage = HomePage (List.map (gotContentToContent model.allTags) contentsResponse.contents)
                            }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
