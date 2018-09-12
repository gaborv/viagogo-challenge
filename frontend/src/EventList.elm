module EventList exposing (main)

import Browser
import Domain.Event as Domain
import Domain.Location as Location
import Grouping
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import List.Extra as List
import Time.DateTime as Time
import Time


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = LoadingEvents Flags Time.Posix
    | EventsLoaded AppState
    | ApiCallFailed String


type alias Flags =
    { longitude : Float
    , latitude : Float
    , accessToken : String
    , artistId : Int
    }


type alias AppState =
    { estimatedLocation : Location.Location
    , now : Time.Posix
    , accessToken : String
    , artistId : Int
    , eventsData : List Domain.Event
    , selectedGrouping : GroupingType
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( LoadingEvents flags (Time.millisToPosix 1), getEventsApiRequest flags.artistId flags.accessToken )


getEventsApiRequest : Int -> String -> Cmd Msg
getEventsApiRequest artistId accessToken =
    Domain.getEvents artistId accessToken
        |> Http.send
            (\result ->
                case result of
                    Ok events ->
                        EventsReceived events

                    Err error ->
                        ErrorOccuredOnApiCall error
            )

------------------------
-- Messages and update


type Msg
    = EventsReceived (List Domain.Event)
    | ErrorOccuredOnApiCall Http.Error
    | TimeTick Time.Posix
    | GroupBy GroupingType


type GroupingType
    = GroupByDate
    | GroupByDistance


subscriptions _ =
    Time.every (3 * 1000) TimeTick

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( LoadingEvents flags _, TimeTick time ) ->
            ( LoadingEvents flags time, Cmd.none)

        ( LoadingEvents flags time, EventsReceived events ) ->
            let
                appState = 
                    { accessToken = flags.accessToken
                    , artistId = flags.artistId
                    , estimatedLocation = Location.fromCoordinates flags.latitude flags.longitude
                    , now = time
                    , eventsData = events
                    , selectedGrouping = GroupByDistance
                    }
            in
                ( EventsLoaded appState, Cmd.none )

        ( EventsLoaded state, TimeTick now) ->
            let
                newState =
                    { state 
                        | now = now
                    }
            in
                ( EventsLoaded newState, getEventsApiRequest state.artistId state.accessToken )

        ( EventsLoaded state, GroupBy newGroupingType) ->
            let
                newState =
                    { state 
                        | selectedGrouping = newGroupingType
                    }
            in
                ( EventsLoaded newState, Cmd.none )

        ( EventsLoaded state, EventsReceived events ) ->
            let
                newState =
                    { state 
                        | eventsData = events
                    }
            in
                ( EventsLoaded newState, Cmd.none )

        ( LoadingEvents _ _, ErrorOccuredOnApiCall err ) ->
            ( ApiCallFailed "A communication error occured", Cmd.none )

        -- err |> Debug.toString
        _ ->
            ( model, Cmd.none )



-----------------------------
-- VIEW


view model =
    case model of
        LoadingEvents _ _ ->
            loadingView

        EventsLoaded appState ->
            eventsView appState

        ApiCallFailed errorMsg ->
            errorView errorMsg


errorView errorMsg =
    div []
        [ text "Could not query events: "
        , text errorMsg
        ]


loadingView =
    text "Loading..."


venueDistanceGrouping userLocation =
    [ { title = "Nearby concerts"
      , filter = \event -> (userLocation |> Location.distanceFrom event.venue.location |> Location.inKm) < 120
      , specialItemSelector = List.minimumBy .minimumPrice
      }
    , { title = "Concerts in 300 km"
      , filter = \event -> (userLocation |> Location.distanceFrom event.venue.location |> Location.inKm) < 300
      , specialItemSelector = List.minimumBy .minimumPrice
      }
    , { title = "Concerts in 800 km"
      , filter = \event -> (userLocation |> Location.distanceFrom event.venue.location |> Location.inKm) < 800
      , specialItemSelector = List.minimumBy .minimumPrice
      }
    , { title = "Farther away", filter = \_ -> True, specialItemSelector = List.minimumBy .minimumPrice }
    ]


eventDateGrouping now =
    [ { title = "Next seven days"
      , filter = \event -> ((now |> Time.fromPosix |> Time.delta event.startsAt).days |> Debug.log "Time delta") <= 7
      , specialItemSelector = List.minimumBy .minimumPrice
      }
    , { title = "Next 30 days"
      , filter = \event -> (now |> Time.fromPosix |> Time.delta event.startsAt).days <= 30
      , specialItemSelector = List.minimumBy .minimumPrice
      }
    , { title = "Next 6 months"
      , filter = \event -> (now |> Time.fromPosix |> Time.delta event.startsAt).months <= 6
      , specialItemSelector = List.minimumBy .minimumPrice
      }
    , { title = "Later", filter = \_ -> True, specialItemSelector = List.minimumBy .minimumPrice }
    ]

eventsView : AppState -> Html Msg
eventsView appState =
    let
        selectedGrouping =
            case appState.selectedGrouping of
                GroupByDate ->
                    eventDateGrouping appState.now
                
                GroupByDistance ->
                    venueDistanceGrouping appState.estimatedLocation

        eventsHtml =
            appState.eventsData
                |> Grouping.showInGroups
                    selectedGrouping
                    Domain.viewEvent
    in
    div [ class "row" ]
        [ div [ class "col-xl-3" ]
            [ button [ type_ "button", class "btn btn-outline-secondary m-3", onClick (GroupBy GroupByDistance)]
                [ text "Group by distance of venue" ]
            , button [ type_ "button", class "btn btn-outline-secondary m-3", onClick (GroupBy GroupByDate)]
                [ text "Group by date of concert" ]
            ]
        , div [ class "col-xl-9" ] [ eventsHtml ]
        ]
