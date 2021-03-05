port module Ports exposing (sendTitle, title)

import AppModel exposing (Model, Page(..))
import Content.Model exposing (ContentText(..))
import Content.Util exposing (contentById)
import Tag.Util exposing (tagById)


port title : String -> Cmd a


defaultTitleCmd =
    title "Philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage ->
            defaultTitleCmd

        ContentPage contentId ->
            case contentById model.allContents contentId of
                Just content ->
                    case content.title of
                        Just exists ->
                            title (exists ++ " - Philocoder")

                        Nothing ->
                            case content.text of
                                Text exists ->
                                    title (String.left 7 exists ++ "... - Philocoder")

                                NotRequestedYet ->
                                    defaultTitleCmd

                Nothing ->
                    Cmd.none

        TagPage tagId ->
            case tagById model.allTags tagId of
                Just tag ->
                    title (tag.name ++ " - Philocoder")

                Nothing ->
                    Cmd.none

        NotFoundPage ->
            title "Oops - Not Found"
