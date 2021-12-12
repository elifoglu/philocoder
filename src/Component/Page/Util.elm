module Component.Page.Util exposing (..)


flipBoolAndToStr : Bool -> String
flipBoolAndToStr bool =
    if bool == True then
        "false"

    else
        "true"
