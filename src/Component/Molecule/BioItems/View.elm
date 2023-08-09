module BioItems.View exposing (viewBioItemsDiv)

import App.Msg exposing (Msg)
import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import BioItem.Util exposing (getBioItemById, separatorBioItem)
import BioItem.View exposing (viewBioItemDiv)
import Html exposing (Html, div, span)
import Html.Attributes exposing (style)


viewBioItemsDiv : Maybe BioItem -> List BioItem -> BioGroup -> Html Msg
viewBioItemsDiv bioItemInfoToShow bioItems activeBioGroup =
    let
        orderedBioItems =
            activeBioGroup.bioItemOrder
                |> List.map (getBioItemById bioItems)
    in
    div [ style "margin-top" "20px", style "margin-bottom" "40px" ]
        (orderedBioItems
            |> List.filter (bioItemIsMemberOfActiveGroup activeBioGroup)
            |> List.map (viewBioItemDiv bioItemInfoToShow)
            |> List.intersperse (span [] [])
        )


bioItemIsMemberOfActiveGroup : BioGroup -> BioItem -> Bool
bioItemIsMemberOfActiveGroup activeBioGroup bioItem =
    if bioItem == separatorBioItem then
        True

    else
        bioItem.groups
            |> List.any (\bioGroupId -> bioGroupId == getBioGroupIdOfBioGroupUrl activeBioGroup.url)


getBioGroupIdOfBioGroupUrl : String -> Int
getBioGroupIdOfBioGroupUrl url =
    case url of
        "some" -> 1
        "descriptive" -> 2
        "valued" -> 17
        "interests" -> 3
        "activities" -> 20
        "music" -> 7
        "books" -> 13
        "movies" -> 8
        "series" -> 10
        "cartoons" -> 11
        "anime" -> 12
        "sports" -> 16
        "games" -> 14
        "yt" -> 15
        "future" -> 5
        "info" -> 9
        "link" -> 6
        "whole" -> 0
        _ -> 99999
