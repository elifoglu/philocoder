module BioItems.View exposing (viewBioItemsDiv)

import App.Model exposing (Theme)
import App.Msg exposing (Msg)
import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import BioItem.Util exposing (getBioItemById, separatorBioItem)
import BioItem.View exposing (viewBioItemDiv)
import Html exposing (Html, div, span)
import Html.Attributes exposing (style)


viewBioItemsDiv : Theme -> Maybe BioItem -> List BioItem -> BioGroup -> Html Msg
viewBioItemsDiv activeTheme bioItemInfoToShow bioItems activeBioGroup =
    let
        orderedBioItems =
            activeBioGroup.bioItemOrder
                |> List.map (getBioItemById bioItems)
    in
    div [ style "margin-top" "20px", style "margin-bottom" "40px" ]
        (orderedBioItems
            |> List.filter (bioItemIsMemberOfActiveGroup activeBioGroup)
            |> List.map (viewBioItemDiv activeTheme bioItemInfoToShow)
            |> List.intersperse (span [] [])
        )


bioItemIsMemberOfActiveGroup : BioGroup -> BioItem -> Bool
bioItemIsMemberOfActiveGroup activeBioGroup bioItem =
    if bioItem == separatorBioItem then
        True

    else
        bioItem.groups
            |> List.any (\bioGroupId -> bioGroupId == activeBioGroup.bioGroupId)
