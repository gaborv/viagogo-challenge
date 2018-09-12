module EventList exposing
    ( main
    , reactor
    )

import Browser
import Domain.Event as Domain
import Grouping
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import List.Extra as List
import Domain.Location as Location
import Time.DateTime as Time


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


reactor =
    Browser.element
        { init = \() -> init defaultFlags
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Model
    = LoadingEvents Flags
    | EventsLoaded Flags (List Domain.Event)
    | ApiCallFailed String


type alias Flags =
    { longitude : Float
    , latitude : Float
    , accessToken : String
    , artistId : Int
    }


defaultFlags : Flags
defaultFlags =
    { latitude = 47.498185
    , longitude = 19.040073
    , accessToken = "<accesstoken>"
    , artistId = 11881
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        apiRequest =
            Domain.getEvents flags.artistId flags.accessToken
                |> Http.send
                    (\result ->
                        case result of
                            Ok events ->
                                EventsReceived events

                            Err error ->
                                ErrorOccuredOnApiCall error
                    )
    in
    ( LoadingEvents flags, apiRequest )


type Msg
    = EventsReceived (List Domain.Event)
    | ErrorOccuredOnApiCall Http.Error
    | Other


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( LoadingEvents flags, EventsReceived events ) ->
            ( EventsLoaded flags events, Cmd.none )

        ( LoadingEvents _, ErrorOccuredOnApiCall err ) ->
            ( ApiCallFailed "A communication error occured", Cmd.none )

        -- err |> Debug.toString
        _ ->
            ( model, Cmd.none )



-----------------------------
-- VIEW


view model =
    case model of
        LoadingEvents _ ->
            loadingView

        EventsLoaded flags events ->
            eventsView flags events

        ApiCallFailed errorMsg ->
            errorView errorMsg


errorView errorMsg =
    div []
        [ text "Could not query events: "
        , text errorMsg
        ]


loadingView =
    text "Loading..."


eventsView : Flags -> List Domain.Event -> Html msg
eventsView flags events =
    let
        userLocation =
            Location.fromCoordinates flags.latitude flags.longitude
    in
    events
        |> Grouping.showInGroups
            [ { title = "Nearby concerts"
              , filter = \event -> (userLocation |> Location.distanceFrom event.venue.location |> Location.inKm |> Debug.log "Distance") < 120
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
            Domain.viewEvent
