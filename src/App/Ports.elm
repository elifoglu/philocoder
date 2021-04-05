port module App.Ports exposing (sendTitle, title)

import App.Model exposing (Initializable(..), MaySendRequest(..), Model, Page(..))


port title : String -> Cmd a


sendDefaultTitle =
    title "Philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage _ ->
            sendDefaultTitle

        ContentPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized content ->
                    case content.title of
                        Just exists ->
                            title (exists ++ " - Philocoder")

                        Nothing ->
                            title (String.left 7 content.text ++ "... - Philocoder")

        TagPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized ( tag, _, pagination ) ->
                    if pagination.currentPage == 1 then
                        title (tag.name ++ " - Philocoder")

                    else
                        title (tag.name ++ " " ++ " (" ++ String.fromInt pagination.currentPage ++ ") - Philocoder")

        NotFoundPage ->
            title "Oops - Not Found"

        CreateContentPage _ ->
            title "Create new content - Philocoder"

        UpdateContentPage status ->
            case status of
                NoRequestSentYet ( _, _, contentId ) ->
                    title <| "Update content " ++ String.fromInt contentId ++ " - Philocoder"

                _ ->
                    Cmd.none

        _ ->
            Cmd.none
