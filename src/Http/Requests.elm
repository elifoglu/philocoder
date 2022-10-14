module Requests exposing (createNewTag, getAllRefData, getBio, getBioPageIcons, getContent, getIcons, getTagContents, getTagDataResponse, getTimeZone, postNewContent, previewContent, updateExistingContent, updateExistingTag)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, IconInfo, ReadingMode(..), UpdateContentPageModel, UpdateTagPageModel, createContentPageModelEncoder, createTagPageModelEncoder, updateContentPageModelEncoder, updateTagPageModelEncoder)
import App.Msg exposing (Msg(..), PreviewContentModel(..))
import DataResponse exposing (ContentID, bioResponseDecoder, contentDecoder, contentsResponseDecoder, gotAllRefDataDecoder, tagDataResponseDecoder)
import Http
import Tag.Model exposing (Tag)
import Task
import Time


apiURL =
    "http://localhost:8090/"


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform GotTimeZone Time.here


getTagDataResponse : Cmd Msg
getTagDataResponse =
    Http.get
        { url =
            apiURL ++ "tags"
        , expect = Http.expectJson GotTagDataResponse tagDataResponseDecoder
        }


getTagContents : Tag -> Maybe Int -> ReadingMode -> Cmd Msg
getTagContents tag maybePage readingMode =
    Http.get
        { url =
            apiURL
                ++ "contents?tagId="
                ++ tag.tagId
                ++ (case maybePage of
                        Just page ->
                            "&page=" ++ String.fromInt page

                        Nothing ->
                            ""
                   )
                ++ (case readingMode of
                        NotSelectedYet ->
                            "&blogMode=false"

                        BlogContents ->
                            "&blogMode=true"

                        AllContents ->
                            "&blogMode=false"
                   )
        , expect = Http.expectJson (GotContentsOfTag tag) contentsResponseDecoder
        }


getContent : Int -> Cmd Msg
getContent contentId =
    Http.get
        { url = apiURL ++ "contents/" ++ String.fromInt contentId
        , expect = Http.expectJson GotContent contentDecoder
        }


getAllRefData : Cmd Msg
getAllRefData =
    Http.get
        { url = apiURL ++ "ref-data"
        , expect = Http.expectJson GotAllRefData gotAllRefDataDecoder
        }


postNewContent : CreateContentPageModel -> Cmd Msg
postNewContent model =
    Http.post
        { url = apiURL ++ "contents"
        , body = Http.jsonBody (createContentPageModelEncoder model)
        , expect = Http.expectJson GotContent contentDecoder
        }


updateExistingContent : ContentID -> UpdateContentPageModel -> Cmd Msg
updateExistingContent contentId model =
    Http.post
        { url = apiURL ++ "contents/" ++ String.fromInt contentId
        , body = Http.jsonBody (updateContentPageModelEncoder contentId model)
        , expect = Http.expectJson GotContent contentDecoder
        }


previewContent : PreviewContentModel -> Cmd Msg
previewContent model =
    case model of
        PreviewForContentCreate createContentPageModel ->
            Http.post
                { url = apiURL ++ "previewContent"
                , body = Http.jsonBody (createContentPageModelEncoder createContentPageModel)
                , expect = Http.expectJson (GotContentToPreviewForCreatePage createContentPageModel) contentDecoder
                }

        PreviewForContentUpdate contentID updateContentPageModel ->
            Http.post
                { url = apiURL ++ "previewContent"
                , body = Http.jsonBody (updateContentPageModelEncoder contentID updateContentPageModel)
                , expect = Http.expectJson (GotContentToPreviewForUpdatePage contentID updateContentPageModel) contentDecoder
                }


createNewTag : CreateTagPageModel -> Cmd Msg
createNewTag model =
    Http.post
        { url = apiURL ++ "tags"
        , body = Http.jsonBody (createTagPageModelEncoder model)
        , expect = Http.expectString GotDoneResponse
        }


updateExistingTag : String -> UpdateTagPageModel -> Cmd Msg
updateExistingTag tagId model =
    Http.post
        { url = apiURL ++ "tags/" ++ tagId
        , body = Http.jsonBody (updateTagPageModelEncoder model)
        , expect = Http.expectString GotDoneResponse
        }


aboutMeIcon : IconInfo
aboutMeIcon =
    { urlToNavigate = "https://about.me/m.e", iconImageUrl = "/aboutme.svg", marginLeft = "4px" }


bioPageIcon : IconInfo
bioPageIcon =
    { urlToNavigate = "/me", iconImageUrl = "/bio.svg", marginLeft = "5px" }

readMeIcon : IconInfo
readMeIcon =
    { urlToNavigate = "/tags/beni_oku", iconImageUrl = "/question-mark.svg", marginLeft = "4px" }


getBioPageIcons : Bool -> List IconInfo
getBioPageIcons showAdditionalIcons =
    [ aboutMeIcon, readMeIcon ]
        ++ getAdditionalIcons showAdditionalIcons


getIcons : Bool -> List IconInfo
getIcons showAdditionalIcons =
    [ aboutMeIcon, bioPageIcon, readMeIcon ]
        ++ getAdditionalIcons showAdditionalIcons


getAdditionalIcons : Bool -> List IconInfo
getAdditionalIcons showAdditionalIcons =
    if not showAdditionalIcons then
        []

    else
        [ { urlToNavigate = "https://philocoder.medium.com/", iconImageUrl = "/medium.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://github.com/elifoglu", iconImageUrl = "/github.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://open.spotify.com/user/215irwufih45cpoovmxs2r25q/", iconImageUrl = "/spotify.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://eksisozluk.com/biri/ajora", iconImageUrl = "/eksi.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://twitter.com/philocoder", iconImageUrl = "/twitter.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://youtube.com/ajora", iconImageUrl = "/youtube.svg", marginLeft = "4px" }
        ]


getBio : Cmd Msg
getBio =
    Http.get
        { url = apiURL ++ "bio"
        , expect = Http.expectJson GotBioResponse bioResponseDecoder
        }
