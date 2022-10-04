module BioGroup.View exposing (viewBioGroup, viewBioGroupInfoDiv)

import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import Html exposing (Html, button, div, input, p, span, text)
import Html.Attributes exposing (checked, class, style, type_)
import Html.Events exposing (onCheck, onClick)
import Markdown


viewBioGroup : BioGroup -> Html Msg
viewBioGroup bioGroup =
    button [ class (decideBioGroupClass bioGroup), onClick (ClickOnABioGroup bioGroup.bioGroupID) ] [ text bioGroup.title ]


decideBioGroupClass : BioGroup -> String
decideBioGroupClass bioGroup =
    if bioGroup.isActive then
        "bioGroup bioGroup-active"

    else
        "bioGroup"


viewBioGroupInfoDiv : BioGroup -> Html Msg
viewBioGroupInfoDiv bioGroup =
    case bioGroup.info of
        Just info ->
            if bioGroup.displayInfo then
                p [ class "bioGroupInfoP" ]
                    [ Markdown.toHtml [ class "markdownDiv bioGroupInfoP" ] info
                    , span [ style "font-size" "12px" ]
                        [ input [ type_ "checkbox", checked (not bioGroup.displayInfo), onCheck (BioGroupDisplayInfoChanged bioGroup) ] []
                        , text "okudum, anladım, onaylıyorum"
                        ]
                    ]

            else
                text ""

        Nothing ->
            div [] []
