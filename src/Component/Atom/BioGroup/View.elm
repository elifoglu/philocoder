module BioGroup.View exposing (viewBioGroup, viewBioGroupInfoDiv)

import App.IconUtil exposing (getIconPath)
import App.Model exposing (Theme)
import App.Msg exposing (Msg(..))
import BioGroup.Model exposing (BioGroup)
import Html exposing (Html, button, div, img, p, span, text)
import Html.Attributes exposing (class, src, style)
import Html.Events exposing (onClick)
import Markdown


viewBioGroup : Theme -> BioGroup -> Html Msg
viewBioGroup activeTheme bioGroup =
    span []
        [ if String.startsWith "/" bioGroup.title then
            if bioGroup.url == "home" && bioGroup.isActive then
                text ""

            else
                let
                    iconName =
                        String.dropLeft 1 bioGroup.title
                in
                img [ class (decideBioGroupClass bioGroup), src (getIconPath activeTheme iconName), onClick (ClickOnABioGroup bioGroup.url) ] []

          else
            button [ class (decideBioGroupClass bioGroup), onClick (ClickOnABioGroup bioGroup.url) ]
                [ text bioGroup.title ]
        , case bioGroup.info of
            Just _ ->
                if String.startsWith "/" bioGroup.title then
                    text ""

                else
                    span [ style "font-size" "12px" ]
                        [ img [ onClick (BioGroupDisplayInfoChanged bioGroup), class "openBioGroupInfo", src (getProperInfoIcon activeTheme bioGroup) ] []
                        ]

            Nothing ->
                text ""
        ]


getProperInfoIcon : Theme -> BioGroup -> String
getProperInfoIcon activeTheme bioGroup =
    if bioGroup.isActive && bioGroup.displayInfo then
        (getIconPath activeTheme "info")

    else
        (getIconPath activeTheme "info-gray")


decideBioGroupClass : BioGroup -> String
decideBioGroupClass bioGroup =
    if bioGroup.isActive then
        if String.startsWith "/" bioGroup.title then
            "bioGroup-iconish bioGroup-iconish-active"

        else
            "bioGroup bioGroup-active"

    else if String.startsWith "/" bioGroup.title then
        "bioGroup-iconish"

    else
        "bioGroup"


viewBioGroupInfoDiv : BioGroup -> Html Msg
viewBioGroupInfoDiv bioGroup =
    case bioGroup.info of
        Just info ->
            if bioGroup.displayInfo then
                div [ class "bioGroupInfoContainer" ]
                    [ p [ class "bioGroupInfoP" ]
                        [ Markdown.toHtml [ class "markdownDiv" ] info
                        ]
                    ]

            else
                text ""

        Nothing ->
            div [] []
