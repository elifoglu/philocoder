module BioGroups.View exposing (allBioGroupsAreActive, makeAllBioGroupsNonActive, viewBioGroupsDiv)

import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import BioGroup.View exposing (viewBioGroup)
import Html exposing (Html, div, span)
import Html.Attributes exposing (style)


viewBioGroupsDiv : List BioGroup -> Html Msg
viewBioGroupsDiv bioGroups =
    div [ style "margin-top" "20px" ]
        (viewBioGroups bioGroups)


viewBioGroups : List BioGroup -> List (Html Msg)
viewBioGroups bioGroups =
    bioGroups
        |> List.map viewBioGroup
        |> List.intersperse (span [] [])


allBioGroupsAreActive : List BioGroup -> Bool
allBioGroupsAreActive bioGroups =
    let
        bioGroupsButTumuIsExcluded =
            List.filter (\bioGroup -> bioGroup.bioGroupID /= 0) bioGroups
    in
    List.all (\bioGroup -> bioGroup.isActive) bioGroupsButTumuIsExcluded


makeAllBioGroupsNonActive : List BioGroup -> List BioGroup
makeAllBioGroupsNonActive bioGroups =
    bioGroups
        |> List.map (\bioGroup -> { bioGroup | isActive = False })
