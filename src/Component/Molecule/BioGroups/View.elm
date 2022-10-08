module BioGroups.View exposing (makeAllBioGroupsNonActive, viewBioGroupsDiv)

import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import BioGroup.View exposing (viewBioGroup)
import Html exposing (Html, div)
import Html.Attributes exposing (style)


viewBioGroupsDiv : List BioGroup -> Html Msg
viewBioGroupsDiv bioGroups =
    div [ style "margin-top" "20px" ]
        (viewBioGroups bioGroups)


viewBioGroups : List BioGroup -> List (Html Msg)
viewBioGroups bioGroups =
    bioGroups
        |> List.map viewBioGroup


makeAllBioGroupsNonActive : List BioGroup -> List BioGroup
makeAllBioGroupsNonActive bioGroups =
    bioGroups
        |> List.map (\bioGroup -> { bioGroup | isActive = False })
