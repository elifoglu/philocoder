port module App.Ports exposing (sendTitle, title)

import App.Model exposing (Model, Page(..))


port title : String -> Cmd a


sendDefaultTitle =
    title "Philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage _ ->
            sendDefaultTitle

        ContentPage content ->
            case content.title of
                Just exists ->
                    title (exists ++ " - Philocoder")

                Nothing ->
                    title (String.left 7 content.text ++ "... - Philocoder")

        TagPage tag _ ->
            title (tag.name ++ " - Philocoder")

        NotFoundPage ->
            title "Oops - Not Found"

        _ ->
            Cmd.none
