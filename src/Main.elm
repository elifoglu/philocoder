module Main exposing (main)

import App.Model exposing (..)
import App.Msg exposing (ContentInputType(..), Msg(..), TagInputType(..))
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import BioGroup.Util exposing (changeActivenessIfIdMatches, changeDisplayInfoIfIdMatchesAndGroupIsActive, gotBioGroupToBioGroup)
import BioGroups.View exposing (makeAllBioGroupsNonActive)
import BioItem.Util exposing (gotBioItemToBioItem)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Content.Model exposing (Content)
import Content.Util exposing (gotContentToContent)
import ForceDirectedGraph exposing (graphSubscriptions, initGraphModel, updateGraph)
import List
import Pagination.Model exposing (Pagination)
import Requests exposing (createNewTag, getAllRefData, getBio, getContent, getTagContents, getTagDataResponseForContentPage, getTagDataResponseForHomePage, getTagDataResponseForTagPage, getTimeZone, postNewContent, previewContent, updateExistingContent, updateExistingTag)
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


getCmdToSendByPage : Model -> Cmd Msg
getCmdToSendByPage model =
    case model.activePage of
        ContentPage status ->
            case status of
                NonInitialized ( contentId, maybeAllTags ) ->
                    case maybeAllTags of
                        Just _ ->
                            getContent contentId

                        Nothing ->
                            getTagDataResponseForContentPage

                Initialized _ ->
                    Cmd.none

        TagPage status ->
            case status of
                NonInitialized initializableTagPageModel ->
                    case initializableTagPageModel.maybeAllTags of
                        Nothing ->
                            getTagDataResponseForTagPage

                        Just allTags ->
                            case tagById allTags initializableTagPageModel.tagId of
                                Just tag ->
                                    getTagContents tag initializableTagPageModel.maybePage initializableTagPageModel.readingMode

                                Nothing ->
                                    Cmd.none

                Initialized _ ->
                    Cmd.none

        BioPage maybeData ->
            case maybeData of
                Just _ ->
                    sendTitle model

                Nothing ->
                    Cmd.batch [ getBio, sendTitle model ]

        HomePage _ _ _ _ _ ->
            getTagDataResponseForHomePage

        _ ->
            Cmd.none


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        page =
            pageBy url

        model =
            Model "log" key page False Time.utc
    in
    ( model
    , Cmd.batch [ getCmdToSendByPage model, getTimeZone ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTagDataResponseForHomePage res ->
            case res of
                Ok gotTagDataResponse ->
                    let
                        allTags =
                            List.map gotTagToTag gotTagDataResponse.allTags

                        blogModeTags =
                            List.map gotTagToTag gotTagDataResponse.blogModeTags

                        updatedHomePage =
                            case model.activePage of
                                HomePage _ _ readingMode maybeAllRefData maybeGraphModel ->
                                    HomePage allTags blogModeTags readingMode maybeAllRefData maybeGraphModel

                                _ ->
                                    MaintenancePage
                    in
                    ( { model
                        | activePage = updatedHomePage
                      }
                    , getAllRefData
                    )

                Err _ ->
                    ( { model
                        | activePage = MaintenancePage
                      }
                    , Cmd.none
                    )

        GotTagDataResponseForTagPage res ->
            case res of
                Ok gotTagDataResponse ->
                    let
                        updatedTagPage : Page
                        updatedTagPage =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized initializableTagPageModel ->
                                            TagPage (NonInitialized { initializableTagPageModel | maybeAllTags = Just (List.map gotTagToTag gotTagDataResponse.allTags), maybeBlogModeTags = Just (List.map gotTagToTag gotTagDataResponse.blogModeTags) })

                                        _ ->
                                            model.activePage

                                _ ->
                                    model.activePage

                        newModel =
                            { model | activePage = updatedTagPage }
                    in
                    ( newModel, getCmdToSendByPage newModel )

                Err _ ->
                    ( { model
                        | activePage = MaintenancePage
                      }
                    , Cmd.none
                    )

        GotTagDataResponseForContentPage res ->
            case res of
                Ok gotTagDataResponse ->
                    let
                        allTags =
                            List.map gotTagToTag gotTagDataResponse.allTags

                        updatedContentPage =
                            case model.activePage of
                                ContentPage status ->
                                    case status of
                                        NonInitialized ( contentId, _ ) ->
                                            ContentPage (NonInitialized ( contentId, Just allTags ))

                                        _ ->
                                            MaintenancePage

                                _ ->
                                    MaintenancePage

                        newModel =
                            { model | activePage = updatedContentPage }
                    in
                    ( newModel, getCmdToSendByPage newModel )

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
                        allTags =
                            case model.activePage of
                                ContentPage status ->
                                    case status of
                                        NonInitialized ( _, maybeAllTags ) ->
                                            Maybe.withDefault [] maybeAllTags

                                        Initialized ( _, tags ) ->
                                            tags

                                _ ->
                                    []

                        content =
                            gotContentToContent model allTags gotContent

                        newActivePage =
                            case model.activePage of
                                CreateContentPage status ->
                                    case status of
                                        NoRequestSentYet ( _, _ ) ->
                                            CreateContentPage <|
                                                NoRequestSentYet ( contentToCreateContentPageModel content, Nothing )

                                        _ ->
                                            ContentPage <| Initialized ( content, allTags )

                                UpdateContentPage status ->
                                    case status of
                                        NoRequestSentYet ( _, _, contentId ) ->
                                            UpdateContentPage <|
                                                NoRequestSentYet ( contentToUpdateContentPageModel content, Just content, contentId )

                                        _ ->
                                            ContentPage <| Initialized ( content, allTags )

                                _ ->
                                    ContentPage <| Initialized ( content, allTags )

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
                            gotContentToContent model [] gotContentToPreview

                        --FIX TODO all tags geçmen gerekirken empty geçtin, sıkıntı!!!!!!!!
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
                            gotContentToContent model [] gotContentToPreview

                        --FIX TODO all tags geçmen gerekirken empty geçtin, sıkıntı!!!!!!!!
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
                                        NonInitialized nonInitialized ->
                                            Maybe.withDefault 1 nonInitialized.maybePage

                                        _ ->
                                            1

                                _ ->
                                    1

                        pagination =
                            Pagination currentPage contentsResponse.totalPageCount

                        allTags =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            Maybe.withDefault [] nonInitialized.maybeAllTags

                                        _ ->
                                            []

                                _ ->
                                    []

                        allBlogModeTags =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            Maybe.withDefault [] nonInitialized.maybeBlogModeTags

                                        _ ->
                                            []

                                _ ->
                                    []

                        contents : List Content
                        contents =
                            List.map (gotContentToContent model allTags) contentsResponse.contents

                        readingMode =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            nonInitialized.readingMode

                                        _ ->
                                            AllContents

                                _ ->
                                    AllContents

                        newPage =
                            TagPage <|
                                Initialized (InitializedTagPageModel tag contents pagination readingMode allTags allBlogModeTags)

                        newModel =
                            { model | activePage = newPage }
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
                , getCmdToSendByPage newModel
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

                                        OkForBlogMode ->
                                            case input of
                                                "true" ->
                                                    { createContentPageModel | okForBlogMode = True }

                                                "false" ->
                                                    { createContentPageModel | okForBlogMode = False }

                                                _ ->
                                                    { createContentPageModel | okForBlogMode = False }

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

                                        OkForBlogMode ->
                                            case input of
                                                "true" ->
                                                    { updateContentPageModel | okForBlogMode = True }

                                                "false" ->
                                                    { updateContentPageModel | okForBlogMode = False }

                                                _ ->
                                                    { updateContentPageModel | okForBlogMode = False }

                                        ContentToCopy ->
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
                                HomePage [] [] AllContents Nothing Nothing

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
                            case model.activePage of
                                HomePage allTags allBlogModeTags readingMode _ maybeGraphModel ->
                                    case maybeGraphModel of
                                        Just _ ->
                                            model

                                        Nothing ->
                                            { model | activePage = HomePage allTags allBlogModeTags readingMode (Just allRefData) (Just <| initGraphModel allRefData) }

                                _ ->
                                    model
                    in
                    ( newModel, Cmd.none )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        GotTimeZone zone ->
            ( { model | timeZone = zone }, Cmd.none )

        ReadingModeChanged readingMode ->
            let
                newPage =
                    case model.activePage of
                        HomePage allTags blogModeTags _ maybeAllRefData maybeGraphModel ->
                            HomePage allTags blogModeTags readingMode maybeAllRefData maybeGraphModel

                        _ ->
                            model.activePage
            in
            ( { model | activePage = newPage }, Cmd.none )

        ShowAdditionalIcons ->
            ( { model | showAdditionalIcons = not model.showAdditionalIcons }, Cmd.none )

        GotBioResponse result ->
            case result of
                Ok bio ->
                    let
                        bioGroups =
                            List.map gotBioGroupToBioGroup bio.groups

                        bioItems =
                            List.map gotBioItemToBioItem bio.items

                        bioPage =
                            BioPage (Just (BioPageModel bioGroups bioItems Nothing))

                        newModel =
                            { model | activePage = bioPage }
                    in
                    ( newModel, sendTitle newModel )

                Err _ ->
                    ( { model
                        | activePage = MaintenancePage
                      }
                    , Cmd.none
                    )

        ClickOnABioGroup bioGroupId ->
            case model.activePage of
                BioPage maybeData ->
                    case maybeData of
                        Just bioPageModel ->
                            let
                                newBioGroupsAllNonActive =
                                    makeAllBioGroupsNonActive bioPageModel.bioGroups

                                newBioGroups =
                                    List.map (changeActivenessIfIdMatches bioGroupId) newBioGroupsAllNonActive

                                newBioPageModel =
                                    { bioPageModel | bioGroups = newBioGroups }

                                newBioPage =
                                    BioPage (Just newBioPageModel)

                                newModel =
                                    { model | activePage = newBioPage }
                            in
                            ( newModel, sendTitle newModel )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        BioGroupDisplayInfoChanged bioGroup ->
            case model.activePage of
                BioPage maybeData ->
                    case maybeData of
                        Just bioPageModel ->
                            let
                                newBioGroups =
                                    List.map (changeDisplayInfoIfIdMatchesAndGroupIsActive bioGroup.bioGroupID) bioPageModel.bioGroups

                                newBioPageModel =
                                    { bioPageModel | bioGroups = newBioGroups }

                                newBioPage =
                                    BioPage (Just newBioPageModel)
                            in
                            ( { model | activePage = newBioPage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ClickOnABioItemInfo bioItem ->
            case model.activePage of
                BioPage maybeData ->
                    case maybeData of
                        Just bioPageModel ->
                            let
                                newBioItemToShowInfo =
                                    case bioPageModel.bioItemToShowInfo of
                                        Just activeBioItemToShowInfo ->
                                            if activeBioItemToShowInfo.bioItemID == bioItem.bioItemID then
                                                Nothing

                                            else
                                                Just bioItem

                                        Nothing ->
                                            Just bioItem

                                newBioPageModel =
                                    { bioPageModel | bioItemToShowInfo = newBioItemToShowInfo }

                                newBioPage =
                                    BioPage (Just newBioPageModel)
                            in
                            ( { model | activePage = newBioPage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        otherMsg ->
            case model.activePage of
                HomePage allTags allBlogModeTags readingMode maybeAllRefData maybeGraphModel ->
                    case maybeGraphModel of
                        Just graphModel ->
                            ( { model | activePage = HomePage allTags allBlogModeTags readingMode maybeAllRefData (Just <| updateGraph otherMsg graphModel) }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.activePage of
        HomePage allTags _ _ _ maybeGraphModel ->
            case maybeGraphModel of
                Just graphModel ->
                    graphSubscriptions graphModel (List.length allTags)

                Nothing ->
                    Sub.none

        _ ->
            Sub.none
