port module App.Ports exposing (sendTitle, title)

import App.Model exposing (Model, Page(..))
import Content.Util exposing (contentById)
import Tag.Util exposing (tagById)


port title : String -> Cmd a


sendDefaultTitle =
    title "Philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage ->
            sendDefaultTitle

        ContentPage contentId ->
            case contentById model.allContents contentId of
                Just content ->
                    case content.title of
                        Just exists ->
                            title (exists ++ " - Philocoder")

                        Nothing ->
                            title (String.left 7 content.text ++ "... - Philocoder")

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
