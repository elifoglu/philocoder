port module Ports exposing (sendTitle, title)

import AppModel exposing (Model, Page(..))
import Content.Util exposing (contentById)
import Tag.Util exposing (tagById)


port title : String -> Cmd a


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage ->
            title "Philocoder"

        ContentPage contentId ->
            case contentById model.allContents contentId of
                Just content ->
                    title (content.title ++ " - Philocoder")

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
