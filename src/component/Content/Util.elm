module Content.Util exposing (contentById)

import Content.Model exposing (Content)


contentById : List Content -> Int -> Maybe Content
contentById contents id =
    contents
        |> List.filter (\a -> a.contentId == id)
        |> List.head
