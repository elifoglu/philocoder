module Pagination.View exposing (viewPagination)

import App.Model exposing (ReadingMode(..))
import App.Msg exposing (Msg)
import Html exposing (Html, a, button, div, text)
import Html.Attributes exposing (class, href, style)
import Pagination.Model exposing (Pagination)
import Tag.Model exposing (Tag)


viewPagination : Tag -> Pagination -> ReadingMode -> Html Msg
viewPagination tag pagination readingMode =
    if pagination.totalPageCount == 1 then
        div [ style "margin-top" "15px", style "margin-bottom" "15px", style "opacity" "0" ]
            [ text "0" ]

    else
        div [ style "margin-top" "30px", style "margin-bottom" "30px" ]
            (List.range 1 pagination.totalPageCount
                |> List.map (viewPageLinkForTagPage tag pagination.currentPage pagination.totalPageCount readingMode)
            )


viewPageLinkForTagPage : Tag -> Int -> Int -> ReadingMode -> Int -> Html Msg
viewPageLinkForTagPage tag currentPageNumber totalPageCount readingMode pageNumber =
    if currentPageNumber == pageNumber then
        if currentPageNumber == 1 || currentPageNumber == totalPageCount then
            text ""

        else
            button [ class "paginationButton currentPaginationButton" ]
                [ text "|"
                ]

    else
        a [ href ("/tags/" ++ tag.tagId ++ blogModeParamString readingMode ++ pageParamString pageNumber readingMode) ]
            [ button [ class "paginationButton" ]
                [ text <| String.fromInt pageNumber
                ]
            ]


blogModeParamString : ReadingMode -> String
blogModeParamString readingMode =
    case readingMode of
        BlogContents ->
            "?mode=blog"

        AllContents ->
            ""


pageParamString : Int -> ReadingMode -> String
pageParamString pageNumber readingMode =
    if pageNumber == 1 then
        ""

    else
        (case readingMode of
            BlogContents ->
                "&"

            AllContents ->
                "?"
        )
            ++ "page="
            ++ String.fromInt pageNumber
