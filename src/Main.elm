module Main exposing (main)

import App.Model exposing (..)
import App.Msg exposing (ContentInputType(..), Msg(..), TagInputType(..))
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Content.Util exposing (gotContentToContent)
import ForceDirectedGraph exposing (graphSubscriptions, initGraphModel, updateGraph)
import List
import Pagination.Model exposing (Pagination)
import Requests exposing (createNewTag, getAllRefData, getAllTags, getContent, getIconData, getTagContents, getTimeZone, postNewContent, previewContent, updateExistingContent, updateExistingTag)
import Tag.Util exposing (gotTagToTag, tagById)
import Time
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
    ( Model "log" key (pageBy url) [] Nothing getIconData Nothing Time.utc
    , Cmd.batch [ getAllTags, getTimeZone ]
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

                        CreateContentPage status ->
                            case status of
                                NoRequestSentYet _ ->
                                    sendTitle model

                                _ ->
                                    Cmd.none

                        UpdateContentPage status ->
                            case status of
                                NoRequestSentYet ( _, _, contentId ) ->
                                    Cmd.batch [ getContent contentId, sendTitle model ]

                                _ ->
                                    Cmd.none

                        CreateTagPage status ->
                            case status of
                                NoRequestSentYet _ ->
                                    sendTitle model

                                _ ->
                                    Cmd.none

                        UpdateTagPage status ->
                            case status of
                                NoRequestSentYet ( _, _ ) ->
                                    sendTitle model

                                _ ->
                                    Cmd.none

                        HomePage ->
                            getAllRefData

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
                            gotContentToContent model gotContent

                        newActivePage =
                            case model.activePage of
                                CreateContentPage status ->
                                    case status of
                                        NoRequestSentYet ( _, _ ) ->
                                            CreateContentPage <|
                                                NoRequestSentYet ( contentToCreateContentPageModel content, Nothing )

                                        _ ->
                                            ContentPage <| Initialized content

                                UpdateContentPage status ->
                                    case status of
                                        NoRequestSentYet ( _, _, contentId ) ->
                                            UpdateContentPage <|
                                                NoRequestSentYet ( contentToUpdateContentPageModel content, Just content, contentId )

                                        _ ->
                                            ContentPage <| Initialized content

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
                            gotContentToContent model gotContentToPreview
                    in
                    ( { model
                        | activePage = CreateContentPage <| NoRequestSentYet ( createContentPageModel, Just content )
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | activePage = CreateContentPage <| NoRequestSentYet ( createContentPageModel, Nothing ) }
                    , Cmd.none
                    )

        GotContentToPreviewForUpdatePage contentID updateContentPageModel result ->
            case result of
                Ok gotContentToPreview ->
                    let
                        content =
                            gotContentToContent model gotContentToPreview
                    in
                    ( { model
                        | activePage = UpdateContentPage <| NoRequestSentYet ( updateContentPageModel, Just content, contentID )
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | activePage = UpdateContentPage <| NoRequestSentYet ( updateContentPageModel, Nothing, contentID ) }
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
                                            ( tag, List.map (gotContentToContent model) contentsResponse.contents, pagination )
                            }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

                Err _ ->
                    ( model, Cmd.none )

        GoToContent contentID ->
            ( model
            , Cmd.batch [ Nav.pushUrl model.key ("/contents/" ++ String.fromInt contentID), getContent contentID ]
            )

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

        ContentInputChanged inputType input ->
            case model.activePage of
                CreateContentPage status ->
                    case status of
                        NoRequestSentYet ( createContentPageModel, maybeContentToPreview ) ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        Id ->
                                            { createContentPageModel | id = input }

                                        Title ->
                                            { createContentPageModel | title = input }

                                        Text ->
                                            { createContentPageModel | text = input }

                                        Tags ->
                                            { createContentPageModel | tags = input }

                                        Refs ->
                                            { createContentPageModel | refs = input }

                                        Password ->
                                            { createContentPageModel | password = input }

                                        ContentToCopy ->
                                            { createContentPageModel | contentIdToCopy = input }
                            in
                            ( { model | activePage = CreateContentPage <| NoRequestSentYet ( newCurrentPageModel, maybeContentToPreview ) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                UpdateContentPage status ->
                    case status of
                        NoRequestSentYet ( updateContentPageModel, maybeContentToPreview, contentId ) ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        Id ->
                                            updateContentPageModel

                                        Title ->
                                            { updateContentPageModel | title = input }

                                        Text ->
                                            { updateContentPageModel | text = input }

                                        Tags ->
                                            { updateContentPageModel | tags = input }

                                        Refs ->
                                            { updateContentPageModel | refs = input }

                                        Password ->
                                            { updateContentPageModel | password = input }

                                        _ ->
                                            updateContentPageModel
                            in
                            ( { model | activePage = UpdateContentPage <| NoRequestSentYet ( newCurrentPageModel, maybeContentToPreview, contentId ) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CreateContent createContentPageModel ->
            ( { model | activePage = CreateContentPage <| RequestSent "creating content..." }
            , postNewContent createContentPageModel
            )

        PreviewContent previewContentModel ->
            ( model
            , previewContent previewContentModel
            )

        UpdateContent contentID updateContentPageModel ->
            ( { model | activePage = UpdateContentPage <| RequestSent "updating content..." }
            , updateExistingContent contentID updateContentPageModel
            )

        TagInputChanged inputType ->
            case model.activePage of
                CreateTagPage status ->
                    case status of
                        NoRequestSentYet createTagPageModel ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        TagId input ->
                                            { createTagPageModel | tagId = input }

                                        Name input ->
                                            { createTagPageModel | name = input }

                                        ContentSortStrategy input ->
                                            { createTagPageModel | contentSortStrategy = input }

                                        ShowAsTag input ->
                                            { createTagPageModel | showAsTag = input }

                                        ContentRenderType input ->
                                            { createTagPageModel | contentRenderType = input }

                                        ShowContentCount input ->
                                            { createTagPageModel | showContentCount = input }

                                        HeaderIndex input ->
                                            { createTagPageModel | headerIndex = input }

                                        InfoContentId _ ->
                                            createTagPageModel

                                        Pw input ->
                                            { createTagPageModel | password = input }
                            in
                            ( { model | activePage = CreateTagPage <| NoRequestSentYet newCurrentPageModel }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                UpdateTagPage status ->
                    case status of
                        NoRequestSentYet ( updateTagPageModel, tagId ) ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        InfoContentId input ->
                                            { updateTagPageModel | infoContentId = input }

                                        Pw input ->
                                            { updateTagPageModel | password = input }

                                        _ ->
                                            updateTagPageModel
                            in
                            ( { model | activePage = UpdateTagPage <| NoRequestSentYet ( newCurrentPageModel, tagId ) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CreateTag createTagPageModel ->
            ( { model | activePage = CreateTagPage <| RequestSent "creating tag..." }
            , createNewTag createTagPageModel
            )

        UpdateTag tagId updateTagPageModel ->
            ( { model | activePage = UpdateTagPage <| RequestSent "updating tag..." }
            , updateExistingTag tagId updateTagPageModel
            )

        GotDoneResponse res ->
            case res of
                Ok tagId ->
                    ( { model
                        | activePage =
                            if tagId == "done" then
                                HomePage

                            else
                                NotFoundPage
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | activePage = NotFoundPage }, Cmd.none )

        GetContentToCopy contentId ->
            ( model
            , getContent <| Maybe.withDefault 0 (String.toInt contentId)
            )

        GotAllRefData res ->
            case res of
                Ok allRefData ->
                    let
                        newModel =
                            { model | allRefData = Just allRefData, graphModel = Just <| initGraphModel allRefData }
                    in
                    ( newModel, Cmd.none )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        GotTimeZone zone ->
            ( { model | timeZone = zone }, Cmd.none )

        otherMsg ->
            case model.graphModel of
                Just graphModel ->
                    ( { model | graphModel = Just <| updateGraph otherMsg graphModel }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.graphModel of
        Just graphModel ->
            graphSubscriptions graphModel

        Nothing ->
            Sub.none
