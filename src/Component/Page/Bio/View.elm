module Bio.View exposing (..)

import App.Model exposing (BioPageModel)
import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import BioGroup.View exposing (viewBioGroupInfoDiv)
import BioGroups.View exposing (viewBioGroupsDiv)
import BioItems.View exposing (viewBioItemsDiv)
import Html exposing (Html, div)
import Html.Attributes exposing (style)


viewBioPageDiv : BioPageModel -> Html Msg
viewBioPageDiv bioPageModel =
    let
        activeBioGroup =
            bioPageModel.bioGroups
                |> List.filter (\bioGroup -> bioGroup.isActive)
                |> List.head
                |> Maybe.withDefault (BioGroup 0 "" 0 Nothing [] True False)
    in
    div [ style "width" "auto", style "float" "left" ]
        ([ viewBioGroupsDiv bioPageModel.bioGroups ]
            ++ [ viewBioGroupInfoDiv activeBioGroup bioPageModel.bioGroups ]
            ++ [ viewBioItemsDiv bioPageModel.bioItemToShowInfo bioPageModel.bioItems activeBioGroup ]
        )
