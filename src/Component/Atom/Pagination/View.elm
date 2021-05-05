module Pagination.View exposing (viewPagination)

import App.Msg exposing (Msg)
import Html exposing (Html, a, button, div, text)
import Html.Attributes exposing (class, disabled, href, style)
import Pagination.Model exposing (Pagination)
import Tag.Model exposing (Tag)


viewPagination : Tag -> Pagination -> Html Msg
viewPagination tag pagination =
    if pagination.totalPageCount == 1 then
        text ""

    else
        div [ style "margin-top" "30px", style "margin-bottom" "30px" ]
            (List.range 1 pagination.totalPageCount
                |> List.map (viewPageLinkForTagPage tag pagination.currentPage)
            )


viewPageLinkForTagPage : Tag -> Int -> Int -> Html Msg
viewPageLinkForTagPage tag currentPageNumber pageNumber =
    if currentPageNumber == pageNumber then
        button [ class "paginationButton", style "color" "black", disabled True ]
            [ text <| String.fromInt pageNumber ]

    else
        a [ href ("/tags/" ++ tag.tagId ++ pageParamString pageNumber) ]
            [ button [ class "paginationButton" ]
                [ text <| String.fromInt pageNumber
                ]
            ]


pageParamString : Int -> String
pageParamString pageNumber =
    if pageNumber == 1 then
        ""

    else
        "?page=" ++ String.fromInt pageNumber
