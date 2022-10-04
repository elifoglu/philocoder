module BioItems.View exposing (viewBioItemsDiv)

import App.Msg exposing (Msg)
import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import BioItem.Util exposing (getBioItemById)
import BioItem.View exposing (viewBioItemDiv)
import Html exposing (Html, div, span)
import Html.Attributes exposing (style)


viewBioItemsDiv : List BioItem -> BioGroup -> Html Msg
viewBioItemsDiv bioItems activeBioGroup =
    let
        orderedBioItems =
            activeBioGroup.bioItemOrder
                |> List.map (getBioItemById bioItems)
    in
    div [ style "margin-top" "20px" ]
        (orderedBioItems
            |> List.filter (bioItemIsMemberOfActiveGroup activeBioGroup)
            |> List.map viewBioItemDiv
            |> List.intersperse (span [] [])
        )


bioItemIsMemberOfActiveGroup : BioGroup -> BioItem -> Bool
bioItemIsMemberOfActiveGroup activeBioGroup bioItem =
    bioItem.groups
        |> List.any (\bioGroupId -> bioGroupId == activeBioGroup.bioGroupID)
