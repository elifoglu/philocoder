module ForceDirectedGraph exposing (graphSubscriptions, initGraphModel, updateGraph, viewGraph)

import App.Model exposing (Entity, GraphModel, Model)
import App.Msg exposing (Msg(..))
import Browser.Events
import Color
import DataResponse exposing (GotAllRefData, GotRefConnection)
import Force exposing (State)
import Graph exposing (Edge, Graph, Node, NodeContext, NodeId)
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Decode
import List.Extra exposing (getAt)
import Tag.Model exposing (Tag)
import Tuple exposing (first, second)
import TypedSvg exposing (circle, defs, g, line, marker, polygon, svg, title)
import TypedSvg.Attributes exposing (class, fill, id, markerEnd, orient, points, refX, refY, stroke, viewBox)
import TypedSvg.Attributes.InPx exposing (cx, cy, markerHeight, markerWidth, r, strokeWidth, x1, x2, y1, y2)
import TypedSvg.Core exposing (Attribute, Svg, text)
import TypedSvg.Types exposing (Paint(..))


contentsGraph : GotAllRefData -> Graph String ()
contentsGraph gotAllRefData =
    Graph.fromNodeLabelsAndEdgePairs
        gotAllRefData.titlesToShow
        (gotAllRefData.connections
            |> List.map gotRefToPair
        )


gotRefToPair : GotRefConnection -> ( Int, Int )
gotRefToPair gotRef =
    ( gotRef.a
    , gotRef.b
    )


w : Float
w =
    180


h : Float
h =
    180


clientPosXCorrectionValue : Float
clientPosXCorrectionValue =
    58


clientPosYCorrectionValue : Int -> Float
clientPosYCorrectionValue totalTagCount =
    toFloat (179 + (20 * totalTagCount))



--INIT--


initGraphModel : GotAllRefData -> GraphModel
initGraphModel allRefData =
    let
        graph : Graph Entity ()
        graph =
            contentsGraph allRefData
                |> Graph.mapContexts initializeNode

        link : { a | from : b, to : c } -> ( b, c )
        link { from, to } =
            ( from, to )

        forces : List (Force.Force NodeId)
        forces =
            [ Force.links <| List.map link <| Graph.edges graph
            , Force.manyBodyStrength -2 <| List.map .id (Graph.nodes graph)
            , Force.center (w / 2.5) (h / 2)
            ]
    in
    GraphModel Nothing graph (Force.simulation forces)


initializeNode : NodeContext String () -> NodeContext Entity ()
initializeNode ctx =
    { node = { label = Force.entity ctx.node.id ctx.node.label, id = ctx.node.id }
    , incoming = ctx.incoming
    , outgoing = ctx.outgoing
    }


updateGraph : Msg -> GraphModel -> GraphModel
updateGraph msg ({ drag, graph, simulation } as model) =
    case msg of
        Tick t ->
            let
                ( newState, list ) =
                    Force.tick simulation <| List.map .label <| Graph.nodes graph
            in
            case drag of
                Nothing ->
                    GraphModel drag (updateGraphWithList graph list) newState

                Just { current, index } ->
                    GraphModel drag
                        (Graph.update index
                            (Maybe.map (updateNode current))
                            (updateGraphWithList graph list)
                        )
                        newState

        DragStart index xy ->
            GraphModel (Just (App.Model.Drag xy xy index)) graph simulation

        DragAt xy ->
            case drag of
                Just { start, index } ->
                    GraphModel (Just (App.Model.Drag start xy index))
                        (Graph.update index (Maybe.map (updateNode xy)) graph)
                        (Force.reheat simulation)

                Nothing ->
                    GraphModel Nothing graph simulation

        DragEnd xy ->
            case drag of
                Just { start, index } ->
                    GraphModel Nothing
                        (Graph.update index (Maybe.map (updateNode xy)) graph)
                        simulation

                Nothing ->
                    GraphModel Nothing graph simulation

        _ ->
            model


updateNode : ( Float, Float ) -> NodeContext Entity () -> NodeContext Entity ()
updateNode ( x, y ) nodeCtx =
    let
        nodeValue =
            nodeCtx.node.label
    in
    updateContextWithValue nodeCtx { nodeValue | x = x, y = y }


updateGraphWithList : Graph Entity () -> List Entity -> Graph Entity ()
updateGraphWithList =
    let
        graphUpdater value =
            Maybe.map (\ctx -> updateContextWithValue ctx value)
    in
    List.foldr (\node graph -> Graph.update node.id (graphUpdater node) graph)


updateContextWithValue : NodeContext Entity () -> Entity -> NodeContext Entity ()
updateContextWithValue nodeCtx value =
    let
        node =
            nodeCtx.node
    in
    { nodeCtx | node = { node | label = value } }



--VIEW--


viewGraph : List Int -> Maybe GraphModel -> Int -> Svg Msg
viewGraph contentIds maybeModel totalTagCount =
    svg [ viewBox 0 0 w h ] <|
        case maybeModel of
            Just model ->
                [ defs []
                    [ arrowHead ]
                , Graph.edges model.graph
                    |> List.map (linkElement model.graph)
                    |> g [ class [ "links" ] ]
                , Graph.nodes model.graph
                    |> List.map (nodeElement contentIds totalTagCount)
                    |> g [ class [ "nodes" ] ]
                ]

            Nothing ->
                []


linkColor : Color.Color
linkColor =
    Color.rgb255 123 123 123


nodeColor : Color.Color
nodeColor =
    Color.rgb255 0 169 255


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


nodeElement : List Int -> Int -> { a | id : NodeId, label : { b | x : Float, y : Float, value : String } } -> Svg Msg
nodeElement contentIds totalTagCount node =
    circle
        [ r 2.5
        , fill <| Paint nodeColor
        , stroke <| Paint <| Color.rgba 0 0 0 0
        , strokeWidth 7
        , cx node.label.x
        , cy node.label.y
        , onMouseClick contentIds node
        , onMouseDown node.id totalTagCount
        ]
        [ title [] [ text node.label.value ]
        ]


onMouseDown : NodeId -> Int -> Attribute Msg
onMouseDown index totalTagCount =
    Mouse.onDown (\event -> DragStart index ( first event.clientPos - clientPosXCorrectionValue, second event.clientPos - clientPosYCorrectionValue totalTagCount ))


onMouseClick : List Int -> { a | id : NodeId, label : { b | x : Float, y : Float, value : String } } -> Attribute Msg
onMouseClick contentIds node =
    Mouse.onContextMenu (\_ -> GoToContent (Maybe.withDefault 0 (getAt node.id contentIds)))



--SUBSCRIPTIONS--


graphSubscriptions : GraphModel -> Int -> Sub Msg
graphSubscriptions model totalTagCount =
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
                [ Browser.Events.onMouseMove (Decode.map (\event -> DragAt ( first event.clientPos - clientPosXCorrectionValue, second event.clientPos - clientPosYCorrectionValue totalTagCount )) Mouse.eventDecoder)
                , Browser.Events.onMouseUp (Decode.map (\event -> DragEnd ( first event.clientPos - clientPosXCorrectionValue, second event.clientPos - clientPosYCorrectionValue totalTagCount )) Mouse.eventDecoder)
                , Browser.Events.onAnimationFrame Tick
                ]
