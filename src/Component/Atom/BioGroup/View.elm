module BioGroup.View exposing (viewBioGroup, viewBioGroupInfoDiv)

import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import Html exposing (Html, button, div, img, p, span, text)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)
import Markdown


viewBioGroup : BioGroup -> Html Msg
viewBioGroup bioGroup =
    span [ style "white-space" "nowrap" ]
        [ button [ class (decideBioGroupClass bioGroup), onClick (ClickOnABioGroup bioGroup.bioGroupID) ] [ text bioGroup.title ]
        , case bioGroup.info of
            Just _ ->
                span [ style "font-size" "12px" ]
                    [ img [ onClick (BioGroupDisplayInfoChanged bioGroup), class "openBioGroupInfo", src (getProperInfoIcon bioGroup) ] []
                    ]

            Nothing ->
                text ""
        ]


getProperInfoIcon : BioGroup -> String
getProperInfoIcon bioGroup =
    if bioGroup.isActive && bioGroup.displayInfo then
        "info.svg"

    else
        "info-gray.svg"


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
                div [ class "bioGroupInfoContainer" ]
                    [ p [ class "bioGroupInfoP" ]
                        [ Markdown.toHtml [ class "markdownDiv bioGroupInfoP" ] info
                        ]
                    ]

            else
                text ""

        Nothing ->
            div [] []
