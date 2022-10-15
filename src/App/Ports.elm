port module App.Ports exposing (sendTitle, title)

import App.Model exposing (Initializable(..), MaySendRequest(..), Model, Page(..))


port title : String -> Cmd a


sendDefaultTitle =
    title "philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage _ _ _ _ ->
            sendDefaultTitle

        ContentPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized ( content, _ ) ->
                    title (content.beautifiedText ++ " - philocoder")

        TagPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized initialized ->
                    if initialized.pagination.currentPage == 1 then
                        title (initialized.tag.name ++ " - philocoder")

                    else
                        title (initialized.tag.name ++ " " ++ " (" ++ String.fromInt initialized.pagination.currentPage ++ ") - philocoder")

        NotFoundPage ->
            title "*oops* - philocoder"

        CreateContentPage _ ->
            title "create new content - philocoder"

        UpdateContentPage status ->
            case status of
                NoRequestSentYet ( _, contentId ) ->
                    title <| "update content - " ++ String.fromInt contentId ++ " - philocoder"

                _ ->
                    Cmd.none

        CreateTagPage _ ->
            title "create new tag - philocoder"

        UpdateTagPage status ->
            case status of
                NoRequestSentYet ( _, tagId ) ->
                    title <| "update tag - " ++ tagId ++ " - philocoder"

                _ ->
                    Cmd.none

        BioPage maybeBioPageModel ->
            case maybeBioPageModel of
                Just bioPageModel ->
                    let
                        maybeActiveBioGroup =
                            bioPageModel.bioGroups
                                |> List.filter (\bioGroup -> bioGroup.isActive)
                                |> List.head
                    in
                    case maybeActiveBioGroup of
                        Just activeBioGroup ->
                            if activeBioGroup.title == "tümü" then
                                title <| "bio - philocoder"

                            else
                                title <| (activeBioGroup.title ++ " - bio - philocoder")

                        Nothing ->
                            title <| "bio - philocoder"

                _ ->
                    title <| "bio - philocoder"

        _ ->
            Cmd.none
