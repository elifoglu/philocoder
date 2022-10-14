module Component.Page.Util exposing (..)

import App.Model exposing (Model)


flipBoolAndToStr : Bool -> String
flipBoolAndToStr bool =
    if bool == True then
        "false"

    else
        "true"


areTagsLoaded : Model -> Bool
areTagsLoaded model =
    model.allTags /= []
