module BioGroups.View exposing (makeAllBioGroupsNonActive, viewBioGroupsDiv)

import App.Model exposing (Theme)
import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import BioGroup.View exposing (viewBioGroup)
import Html exposing (Html, div)
import Html.Attributes exposing (style)


viewBioGroupsDiv : Theme -> List BioGroup -> Html Msg
viewBioGroupsDiv activeTheme bioGroups =
    div [ style "margin-top" "10px" ]
        (viewBioGroups activeTheme bioGroups)


viewBioGroups : Theme -> List BioGroup -> List (Html Msg)
viewBioGroups activeTheme bioGroups =
    bioGroups
        |> List.map (viewBioGroup activeTheme)


makeAllBioGroupsNonActive : List BioGroup -> List BioGroup
makeAllBioGroupsNonActive bioGroups =
    bioGroups
        |> List.map (\bioGroup -> { bioGroup | isActive = False })
