module Bio.View exposing (..)

import App.Model exposing (BioPageModel, Model)
import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import BioGroup.View exposing (viewBioGroupInfoDiv)
import BioGroups.View exposing (viewBioGroupsDiv)
import BioItems.View exposing (viewBioItemsDiv)
import Home.View exposing (viewIconsDiv)
import Html exposing (Html, br, div, hr, p, span)
import Html.Attributes exposing (style)


viewBioPageDiv : Model -> BioPageModel -> Html Msg
viewBioPageDiv model bioPageModel =
    let
        activeBioGroup =
            bioPageModel.bioGroups
                |> List.filter (\bioGroup -> bioGroup.isActive)
                |> List.head
                |> Maybe.withDefault (BioGroup 0 "" 0 Nothing [] True False)
    in
    div [ style "width" "auto", style "float" "left" ]
        ([ viewBioGroupsDiv bioPageModel.bioGroups ]
            ++ [ viewBioGroupInfoDiv activeBioGroup ]
            ++ [ viewBioItemsDiv bioPageModel.bioItemToShowInfo bioPageModel.bioItems activeBioGroup ]
            ++ [ hr [ style "margin-top" "20px", style "margin-bottom" "25px" ] [] ]
            ++ viewIconsDiv model
            ++ [ span [ style "padding-bottom" "30px" ] [ p [] [ br [] [] ] ] ]
        )
