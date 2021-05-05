module Requests exposing (createNewTag, getAllReferences, getAllTags, getContent, getTagContents, postNewContent, previewContent, updateExistingContent, updateExistingTag)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, UpdateContentPageModel, UpdateTagPageModel, createContentPageModelEncoder, createTagPageModelEncoder, updateContentPageModelEncoder, updateTagPageModelEncoder)
import App.Msg exposing (Msg(..), PreviewContentModel(..))
import DataResponse exposing (ContentID, allRefsDecoder, contentDecoder, contentsResponseDecoder, tagsDecoder)
import Http
import Tag.Model exposing (Tag)


apiURL =
    "http://localhost:8090/"


getAllTags : Cmd Msg
getAllTags =
    Http.get
        { url = apiURL ++ "tags"
        , expect = Http.expectJson GotAllTags tagsDecoder
        }


getTagContents : Tag -> Maybe Int -> Cmd Msg
getTagContents tag maybePage =
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
        , expect = Http.expectJson (GotContentsOfTag tag) contentsResponseDecoder
        }


getContent : Int -> Cmd Msg
getContent contentId =
    Http.get
        { url = apiURL ++ "contents/" ++ String.fromInt contentId
        , expect = Http.expectJson GotContent contentDecoder
        }


getAllReferences : Cmd Msg
getAllReferences =
    Http.get
        { url = apiURL ++ "content-refs"
        , expect = Http.expectJson GotAllReferences allRefsDecoder
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
