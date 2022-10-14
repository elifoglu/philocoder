module Component.Page.Util exposing (..)

import Tag.Model exposing (Tag)


flipBoolAndToStr : Bool -> String
flipBoolAndToStr bool =
    if bool == True then
        "false"

    else
        "true"


areTagsLoaded : List Tag -> Bool
areTagsLoaded allTags =
    allTags /= []
