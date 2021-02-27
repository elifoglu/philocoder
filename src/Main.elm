port module Main exposing (..)

import Browser
import Content exposing (Content)
import ContentData exposing (allContents)
import Http
import Json.Decode as D
import List exposing (member)
import Model exposing (..)
import Msg exposing (Msg(..), Tag, tagDecoder)
import Sort exposing (sortContentsByStrategy)
import Tab exposing (Tab)
import View exposing (view)


port title : String -> Cmd a


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( []
    , Http.get
        { url = "http://localhost:8081/tags.txt"
        , expect = Http.expectJson GotTags (D.list tagDecoder)
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabSelected tab ->
            ( List.map (Tab.setActive tab) model, Cmd.none )

        GotTags tagsResult ->
            case tagsResult of
                Err _ ->
                    ( [], Cmd.none )

                Ok tags ->
                    ( List.map tagToTab tags, Cmd.none )


tagToTab : Tag -> Tab
tagToTab tag =
    { name = tag.name
    , contents = sortContentsByStrategy tag.contentSortStrategy (getTabContents tag.name)
    , active = tag.active
    }


getTabContents tabName =
    List.filter (contentBelongsToTab tabName) allContents


contentBelongsToTab : String -> Content -> Bool
contentBelongsToTab tabName content =
    member tabName content.tabs


view =
    View.view


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
