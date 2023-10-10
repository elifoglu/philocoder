module App.IconUtil exposing (getIconPath)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Initializable(..), LocalStorage, MaySendRequest(..), NonInitializedYetTagPageModel, Page(..), ReadingMode(..), Theme(..), UpdateContentPageData, UpdateContentPageModel(..), UpdateTagPageModel)
import Url
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, parse, s, string, top)
import Url.Parser.Query as Query


getIconPath: Theme -> String -> String
getIconPath activeTheme iconName =
    case activeTheme of
        Light ->
            "/" ++ iconName ++ ".svg"

        Dark ->
            "/inverted/" ++ iconName ++ ".png"

