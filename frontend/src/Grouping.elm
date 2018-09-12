module Grouping exposing
    ( GroupDefinition
    , showInGroups
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import List.Extra as List


type alias GroupDefinition item =
    { title : String
    , filter : item -> Bool
    , specialItemSelector : List item -> Maybe item
    }


type alias Grouping item =
    { title : String
    , items : List item
    , specialItemSelector : List item -> Maybe item
    }


groupItems : List (GroupDefinition item) -> List item -> List (Grouping item)
groupItems groupDefinitions allItems =
    groupDefinitions
        |> List.foldl
            (\groupDefinition ( groups, items ) ->
                let
                    ( itemsInGroup, remainingItems ) =
                        items |> List.partition groupDefinition.filter

                    group =
                        { title = groupDefinition.title
                        , items = itemsInGroup
                        , specialItemSelector = groupDefinition.specialItemSelector
                        }
                in
                if itemsInGroup |> List.isEmpty then
                    -- Ignore empty groups:
                    ( groups, remainingItems )

                else
                    ( group :: groups, remainingItems )
            )
            ( [], allItems )
        |> Tuple.first
        |> List.reverse


renderGrouping : (Bool -> item -> Html msg) -> Grouping item -> Html msg
renderGrouping viewItem { title, items, specialItemSelector } =
    let
        specialItem = 
            items |> specialItemSelector
    in
        div []
            [ div [ class "p-2 bg-secondary text-white text-center" ]
                [ h5 [] [ text title ] ]
            , div [ class "p-3 bg-light" ]
                (items 
                    |> List.groupsOf 3 
                    |> List.map 
                        (\rowItems -> 
                            div [class "card-deck"]
                                (rowItems |> List.map (\item -> viewItem (Just item == specialItem) item))
                        )

                )
            ]


showInGroups : List (GroupDefinition item) -> (Bool -> item -> Html msg) -> List item -> Html msg
showInGroups groupDefinitions viewItem items =
    let
        groups =
            items |> groupItems groupDefinitions
    in
    div
        []
        (groups |> List.map (renderGrouping viewItem) |> List.intersperse (div [class "p-4"][]))
