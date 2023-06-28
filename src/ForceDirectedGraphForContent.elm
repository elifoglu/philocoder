module ForceDirectedGraphForContent exposing (graphSubscriptionsForContent, initGraphModelForContent, viewGraphForContent)

import App.GraphModel exposing (GraphModel)
import App.Model exposing (Entity, Model)
import App.Msg exposing (Msg(..))
import Browser.Events
import Color
import Content.Model exposing (GotGraphData, RefConnection)
import DataResponse exposing (ContentID)
import Force exposing (State)
import Graph exposing (Edge, Graph, Node, NodeContext, NodeId)
import Html.Events.Extra.Mouse as Mouse exposing (Button(..), Event)
import Json.Decode as Decode
import List.Extra exposing (getAt)
import Tuple exposing (first, second)
import TypedSvg exposing (circle, defs, g, line, marker, polygon, svg, title)
import TypedSvg.Attributes exposing (class, fill, id, markerEnd, orient, points, refX, refY, stroke, viewBox)
import TypedSvg.Attributes.InPx exposing (cx, cy, markerHeight, markerWidth, r, strokeWidth, x1, x2, y1, y2)
import TypedSvg.Core exposing (Attribute, Svg, text)
import TypedSvg.Types exposing (Paint(..))


graphOfContent : GotGraphData -> Graph String ()
graphOfContent gotGraphData =
    Graph.fromNodeLabelsAndEdgePairs
        gotGraphData.titlesToShow
        (gotGraphData.connections
            |> List.map gotRefToPair
        )


gotRefToPair : RefConnection -> ( Int, Int )
gotRefToPair gotRef =
    ( gotRef.a
    , gotRef.b
    )


w : Float
w =
    250


h : Float
h =
    250


clientPosXCorrectionValue : Float
clientPosXCorrectionValue =
    32


clientPosYCorrectionValue : Float
clientPosYCorrectionValue =
    90



--INIT--


initGraphModelForContent : GotGraphData -> GraphModel
initGraphModelForContent gotGraphData =
    let
        graph : Graph Entity ()
        graph =
            graphOfContent gotGraphData
                |> Graph.mapContexts initializeNode

        link : { a | from : b, to : c } -> ( b, c )
        link { from, to } =
            ( from, to )

        forces : List (Force.Force NodeId)
        forces =
            [ Force.links <| List.map link <| Graph.edges graph
            , Force.manyBodyStrength -2 <| List.map .id (Graph.nodes graph)
            , Force.center (w / 2) (h / 2)
            ]
    in
    GraphModel Nothing graph (Force.simulation forces)


initializeNode : NodeContext String () -> NodeContext Entity ()
initializeNode ctx =
    { node = { label = Force.entity ctx.node.id ctx.node.label, id = ctx.node.id }
    , incoming = ctx.incoming
    , outgoing = ctx.outgoing
    }



--VIEW--


viewGraphForContent : Int -> List Int -> GraphModel -> Maybe ContentID -> Svg Msg
viewGraphForContent idOfContentOfContentPage contentIds graphModel contentToColorize =
    svg [ viewBox 0 0 w h ] <|
        [ defs []
            [ arrowHead ]
        , Graph.edges graphModel.graph
            |> List.map (linkElement graphModel.graph)
            |> g [ class [ "links" ] ]
        , Graph.nodes graphModel.graph
            |> List.map (nodeElement idOfContentOfContentPage contentIds contentToColorize)
            |> g [ class [ "nodes" ] ]
        ]


linkColor : Color.Color
linkColor =
    Color.rgb255 225 225 225


nodeColor : Color.Color
nodeColor =
    Color.rgb255 20 20 20


nodeColorOfCurrentContent : Color.Color
nodeColorOfCurrentContent =
    Color.rgb255 255 32 32


nodeColorOfColorizedContent : Color.Color
nodeColorOfColorizedContent =
    Color.rgb255 248 136 136


selectNodeColor : ContentID -> ContentID -> Maybe ContentID -> Paint
selectNodeColor idOfContentOfContentPage currentContentId maybeContentIdToColorize =
    Paint
        (if currentContentId == idOfContentOfContentPage then
            nodeColorOfCurrentContent

         else
            case maybeContentIdToColorize of
                Just contentIdToColorize ->
                    if contentIdToColorize == currentContentId then
                        nodeColorOfColorizedContent

                    else
                        nodeColor

                Nothing ->
                    nodeColor
        )


arrowHead : Svg msg
arrowHead =
    marker
        [ id "arrowhead"
        , markerWidth 6
        , markerHeight 6
        , refX "7"
        , refY "2"
        , orient "auto"
        , fill <| Paint linkColor
        ]
        [ polygon [ points [ ( 0, 0 ), ( 6, 2 ), ( 0, 4 ) ] ] [] ]


linkElement : Graph Entity () -> Edge () -> Svg msg
linkElement graph edge =
    let
        source =
            Maybe.withDefault (Force.entity 0 "") <| Maybe.map (.node >> .label) <| Graph.get edge.from graph

        target =
            Maybe.withDefault (Force.entity 0 "") <| Maybe.map (.node >> .label) <| Graph.get edge.to graph
    in
    line
        [ strokeWidth 0.9
        , stroke <| Paint linkColor
        , x1 source.x
        , y1 source.y
        , x2 target.x
        , y2 target.y
        , markerEnd "url(#arrowhead)"
        ]
        []


nodeElement : Int -> List Int -> Maybe ContentID -> { a | id : NodeId, label : { b | x : Float, y : Float, value : String } } -> Svg Msg
nodeElement idOfContentOfContentPage contentIds contentToColorize node =
    circle
        [ r <| selectR idOfContentOfContentPage (Maybe.withDefault 0 (getAt node.id contentIds))
        , fill <| selectNodeColor idOfContentOfContentPage (Maybe.withDefault 0 (getAt node.id contentIds)) contentToColorize
        , stroke <| Paint <| Color.rgba 0 0 0 0
        , strokeWidth 7
        , cx node.label.x
        , cy node.label.y
        , onMouseClick
        , onMouseDown contentIds node
        , onMouseOver contentIds node
        , onMouseLeave
        ]
        [ title [] [ text node.label.value ]
        ]


selectR : ContentID -> ContentID -> Float
selectR idOfContentOfContentPage currentContentId =
    if currentContentId == idOfContentOfContentPage then
        3.1

    else
        2.5


onMouseDown : List Int -> { a | id : NodeId, label : { b | x : Float, y : Float, value : String } } -> Attribute Msg
onMouseDown contentIds node =
    Mouse.onDown
        (\event ->
            case event.button of
                MainButton ->
                    GoToContentViaContentGraph (Maybe.withDefault 0 (getAt node.id contentIds)) event.keys.ctrl

                MiddleButton ->
                    DragStart node.id ( setX event, setY event )

                SecondButton ->
                    DragStart node.id ( setX event, setY event )

                _ ->
                    DoNothing
        )


onMouseClick : Attribute Msg
onMouseClick =
    Mouse.onContextMenu (\_ -> DoNothing)


onMouseOver : List Int -> { a | id : NodeId, label : { b | x : Float, y : Float, value : String } } -> Attribute Msg
onMouseOver contentIds node =
    Mouse.onOver (\_ -> ColorizeContentOnGraph (Maybe.withDefault 0 (getAt node.id contentIds)))


onMouseLeave : Attribute Msg
onMouseLeave =
    Mouse.onLeave (\_ -> UncolorizeContentOnGraph)



--this is to prevent the context menu from popping up on right click
--SUBSCRIPTIONS--


graphSubscriptionsForContent : GraphModel -> Sub Msg
graphSubscriptionsForContent model =
    case model.drag of
        Nothing ->
            -- This allows us to save resources, as if the simulation is done, there is no point in subscribing
            -- to the rAF.
            if Force.isCompleted model.simulation then
                Sub.none

            else
                Browser.Events.onAnimationFrame Tick

        Just _ ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map (\event -> DragAt ( setX event, setY event )) Mouse.eventDecoder)
                , Browser.Events.onMouseUp (Decode.map (\event -> DragEnd ( setX event, setY event )) Mouse.eventDecoder)
                , Browser.Events.onAnimationFrame Tick
                ]


setX : Event -> Float
setX event =
    first event.clientPos - clientPosXCorrectionValue


setY : Event -> Float
setY event =
    second event.clientPos - clientPosYCorrectionValue
