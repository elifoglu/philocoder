module Main exposing (main)

import App.Model exposing (..)
import App.Msg exposing (CreateContentInputType(..), Msg(..))
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Content.Util exposing (gotContentToContent)
import List
import Pagination.Model exposing (Pagination)
import Requests exposing (getAllTags, getContent, getHomeContents, getTagContents, postNewContent, previewContent, updateExistingContent)
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
                        HomePage status ->
                            case status of
                                NonInitialized _ ->
                                    getHomeContents

                                Initialized _ ->
                                    Cmd.none

                        ContentPage status ->
                            case status of
                                NonInitialized contentId ->
                                    getContent contentId

                                Initialized _ ->
                                    Cmd.none

                        TagPage status ->
                            case status of
                                NonInitialized ( tagId, maybePage ) ->
                                    case tagById allTags tagId of
                                        Just tag ->
                                            getTagContents tag maybePage

                                        Nothing ->
                                            Cmd.none

                                Initialized _ ->
                                    Cmd.none

                        CreateContentPage _ _ ->
                            sendTitle model

                        UpdateContentPage _ _ contentId ->
                            Cmd.batch [ getContent contentId, sendTitle model ]

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

                        newActivePage =
                            case model.activePage of
                                UpdateContentPage _ _ contentId ->
                                    UpdateContentPage (contentToUpdateContentPageModel content) (Just content) contentId

                                _ ->
                                    ContentPage <| Initialized content

                        newModel =
                            { model
                                | activePage = newActivePage
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

        GotContentToPreviewForCreatePage createContentPageModel result ->
            case result of
                Ok gotContentToPreview ->
                    let
                        content =
                            gotContentToContent model.allTags gotContentToPreview
                    in
                    ( { model
                        | activePage = CreateContentPage createContentPageModel (Just content)
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | activePage = CreateContentPage createContentPageModel Nothing }
                    , Cmd.none
                    )

        GotContentToPreviewForUpdatePage contentID updateContentPageModel result ->
            case result of
                Ok gotContentToPreview ->
                    let
                        content =
                            gotContentToContent model.allTags gotContentToPreview
                    in
                    ( { model
                        | activePage = UpdateContentPage updateContentPageModel (Just content) contentID
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | activePage = UpdateContentPage updateContentPageModel Nothing contentID }
                    , Cmd.none
                    )

        GotContentsOfTag tag result ->
            case result of
                Ok contentsResponse ->
                    let
                        currentPage =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized ( _, maybePage ) ->
                                            Maybe.withDefault 1 maybePage

                                        _ ->
                                            1

                                _ ->
                                    1

                        pagination =
                            Pagination currentPage contentsResponse.totalPageCount

                        newModel =
                            { model
                                | activePage =
                                    TagPage <|
                                        Initialized
                                            ( tag, List.map (gotContentToContent model.allTags) contentsResponse.contents, pagination )
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
                    HomePage status ->
                        case status of
                            NonInitialized _ ->
                                getHomeContents

                            _ ->
                                Cmd.none

                    ContentPage status ->
                        case status of
                            NonInitialized contentId ->
                                getContent contentId

                            _ ->
                                Cmd.none

                    TagPage status ->
                        case status of
                            NonInitialized ( tagId, maybePage ) ->
                                case tagById model.allTags tagId of
                                    Just tag ->
                                        getTagContents tag maybePage

                                    Nothing ->
                                        Cmd.none

                            _ ->
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
                                | activePage = HomePage <| Initialized (List.map (gotContentToContent model.allTags) contentsResponse.contents)
                            }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

                Err _ ->
                    ( model, Cmd.none )

        ContentInputChanged inputType input ->
            case model.activePage of
                CreateContentPage createContentPageModel maybeContentToPreview ->
                    let
                        newCurrentPageModel =
                            case inputType of
                                Id ->
                                    { createContentPageModel | id = input }

                                Title ->
                                    { createContentPageModel | title = input }

                                Text ->
                                    { createContentPageModel | text = input }

                                Date ->
                                    { createContentPageModel | date = input }

                                PublishOrderInDay ->
                                    { createContentPageModel | publishOrderInDay = input }

                                Tags ->
                                    { createContentPageModel | tags = input }

                                Refs ->
                                    { createContentPageModel | refs = input }

                                Password ->
                                    { createContentPageModel | password = input }
                    in
                    ( { model | activePage = CreateContentPage newCurrentPageModel maybeContentToPreview }, Cmd.none )

                UpdateContentPage updateContentPageModel maybeContentToPreview contentId ->
                    let
                        newCurrentPageModel =
                            case inputType of
                                Id ->
                                    updateContentPageModel

                                Title ->
                                    { updateContentPageModel | title = input }

                                Text ->
                                    { updateContentPageModel | text = input }

                                Date ->
                                    { updateContentPageModel | date = input }

                                PublishOrderInDay ->
                                    { updateContentPageModel | publishOrderInDay = input }

                                Tags ->
                                    { updateContentPageModel | tags = input }

                                Refs ->
                                    { updateContentPageModel | refs = input }

                                Password ->
                                    { updateContentPageModel | password = input }
                    in
                    ( { model | activePage = UpdateContentPage newCurrentPageModel maybeContentToPreview contentId }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CreateContent createContentPageModel ->
            ( { model | activePage = CreatingContentPage }
            , postNewContent createContentPageModel
            )

        PreviewContent previewContentModel ->
            ( model
            , previewContent previewContentModel
            )

        UpdateContent contentID updateContentPageModel ->
            ( { model | activePage = UpdatingContentPage }
            , updateExistingContent contentID updateContentPageModel
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
