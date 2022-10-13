port module App.Ports exposing (sendTitle, title)

import App.Model exposing (Initializable(..), MaySendRequest(..), Model, Page(..))


port title : String -> Cmd a


sendDefaultTitle =
    title "philocoder"


sendTitle : Model -> Cmd msg
sendTitle model =
    case model.activePage of
        HomePage ->
            sendDefaultTitle

        ContentPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized content ->
                    case content.title of
                        Just exists ->
                            title (exists ++ " - philocoder")

                        Nothing ->
                            title (String.left 7 content.text ++ "... - philocoder")

        TagPage status ->
            case status of
                NonInitialized _ ->
                    Cmd.none

                Initialized ( tag, _, pagination ) ->
                    if pagination.currentPage == 1 then
                        title (tag.name ++ " - philocoder")

                    else
                        title (tag.name ++ " " ++ " (" ++ String.fromInt pagination.currentPage ++ ") - philocoder")

        NotFoundPage ->
            title "oops - Not Found"

        CreateContentPage _ ->
            title "create new content - philocoder"

        UpdateContentPage status ->
            case status of
                NoRequestSentYet ( _, _, contentId ) ->
                    title <| "update content " ++ String.fromInt contentId ++ " - philocoder"

                _ ->
                    Cmd.none

        CreateTagPage _ ->
            title "create new tag - philocoder"

        UpdateTagPage status ->
            case status of
                NoRequestSentYet ( _, tagId ) ->
                    title <| "update content " ++ tagId ++ " - philocoder"

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
                            title <| (activeBioGroup.title ++ " - kim - philocoder")

                        Nothing ->
                            title <| "kim - philocoder"

                _ ->
                    title <| "kim - philocoder"

        _ ->
            Cmd.none
