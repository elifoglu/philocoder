port module App.Ports exposing (sendTitle, title)

import App.Model exposing (Initializable(..), MaySendRequest(..), Model, Page(..), UpdateContentPageModel(..))


port title : String -> Cmd a


sendDefaultTitle =
    title "philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage _ _ _ ->
            sendDefaultTitle

        ContentPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized content ->
                    case content.title of
                        Just t ->
                            title (t ++ " - philocoder")
                        Nothing ->
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

        CreateContentPage _ ->
            title "create new content - philocoder"

        UpdateContentPage status ->
            case status of
                NotInitializedYet _ ->
                    title <| "update content - philocoder"

                GotContentToUpdate updateContentPageData ->
                    if String.isEmpty updateContentPageData.title then
                        title <| "update content - " ++ String.fromInt updateContentPageData.contentId ++ " - philocoder"

                    else
                        title <| "update content - " ++ updateContentPageData.title ++ " - philocoder"

                UpdateRequestIsSent _ ->
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
                                title <| "me - philocoder"

                            else
                                title <| (activeBioGroup.title ++ " - me - philocoder")

                        Nothing ->
                            title <| "me - philocoder"

                _ ->
                    title <| "me - philocoder"

        NotFoundPage ->
            title "oops - philocoder"

        MaintenancePage ->
            title "bakım çalışması - philocoder"
