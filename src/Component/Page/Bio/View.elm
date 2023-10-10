module Bio.View exposing (..)

import App.Model exposing (BioPageModel, Model, Theme)
import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import BioGroup.View exposing (viewBioGroupInfoDiv)
import BioGroups.View exposing (viewBioGroupsDiv)
import BioItems.View exposing (viewBioItemsDiv)
import Html exposing (Html, div)
import Html.Attributes exposing (style)


viewBioPageDiv : Theme -> BioPageModel -> Html Msg
viewBioPageDiv activeTheme bioPageModel =
    let
        activeBioGroup =
            bioPageModel.bioGroups
                |> List.filter (\bioGroup -> bioGroup.isActive)
                |> List.head
                |> Maybe.withDefault (BioGroup "" "" 0 Nothing 9999 [] True False)
    in
    div [ style "float" "left", style "margin-left" "-4px" ]
        (viewBioGroupsDiv activeTheme bioPageModel.bioGroups
            :: [ viewBioGroupInfoDiv activeBioGroup ]
            ++ [ viewBioItemsDiv activeTheme bioPageModel.bioItemToShowInfo bioPageModel.bioItems activeBioGroup ]
        )
