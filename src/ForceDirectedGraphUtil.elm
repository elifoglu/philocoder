module ForceDirectedGraphUtil exposing (updateGraph)

import App.GraphModel exposing (GraphModel)
import App.Model exposing (Entity, Model)
import App.Msg exposing (Msg(..))
import Browser.Events
import Color
import Content.Model exposing (AllRefData, RefConnection)
import Force exposing (State)
import Graph exposing (Edge, Graph, Node, NodeContext, NodeId)
import Html.Events.Extra.Mouse as Mouse exposing (Event)
import Json.Decode as Decode
import List.Extra exposing (getAt)
import Tuple exposing (first, second)
import TypedSvg exposing (circle, defs, g, line, marker, polygon, svg, title)
import TypedSvg.Attributes exposing (class, fill, id, markerEnd, orient, points, refX, refY, stroke, viewBox)
import TypedSvg.Attributes.InPx exposing (cx, cy, markerHeight, markerWidth, r, strokeWidth, x1, x2, y1, y2)
import TypedSvg.Core exposing (Attribute, Svg, text)
import TypedSvg.Types exposing (Paint(..))


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