module EventList exposing 
    ( main
    , reactor
    )

import Browser
import Event exposing (Event)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
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
    | EventsLoaded Flags (List Event)
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
    , accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOjEyMSwiaWF0IjoxNTM2NjA1MTU0LCJzY29wZSI6IiIsInQiOjAsImp0aSI6IlVaTmZTSHZRbFNJeVMvVVdZZjBMWUhNblZuQWFsbzViVnBkSENlblFrZjU4SVBrS2lRSDNXMGdhWXZWa1ZsOUVTSTMxdlgyWUdDdGxXc3kwenhFcDlFMWU0blRYd2EyWVJ3QjUrcHNaRmQ0PSIsInZnZy1zdiI6Ijk5NWMzNmY4MTQ5NjRlOGZhMGZmYjFkMjRmMGFlZGM3IiwiZXhwIjoxNTM2NjkxNTU0LCJhdXRoLXR5cGUiOjF9.msXe4Pi7kEfgcmO17jFC2SFQjPG24KxFLq_Qeb2mcBo"
    , artistId = 11881
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        apiRequest =
            Event.getEvents flags.artistId flags.accessToken
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
    = EventsReceived (List Event)
    | ErrorOccuredOnApiCall Http.Error
    | Other


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( LoadingEvents flags, EventsReceived events ) ->
            ( EventsLoaded flags events, Cmd.none )

        ( LoadingEvents _, ErrorOccuredOnApiCall err ) ->
            ( ApiCallFailed ("A communication error occured"), Cmd.none )   -- err |> Debug.toString

        _ ->
            ( model, Cmd.none )



-----------------------------
-- VIEW


view model =
    case model of
        LoadingEvents _ ->
            loadingView

        EventsLoaded _ events ->
            eventsView events

        ApiCallFailed errorMsg ->
            errorView errorMsg


errorView errorMsg =
    div []
        [ text "Could not query events: "
        , text errorMsg
        ]

loadingView =
    text "Loading..."


eventsView events =
    div [] (events |> List.map viewEvent)

viewEvent event =
    div []
        [ h1 [] 
            [ text event.venue.name
            , text "––"
            , text event.venue.city
            ]
        , h2 []
            [ text (event.startsAt |> monthAbbrv)
            , text (event.startsAt |> Time.day |> String.fromInt)
            , text ", "
            , text (event.startsAt |> Time.hour |> String.fromInt)
            , text (event.startsAt |> Time.minute |> String.fromInt)
            ]
        ]


monthAbbrv monthSeq =
    case monthSeq |> Time.month of
        1 -> "Jan"
        2 -> "Feb"
        3 -> "Mar"
        4 -> "Apr"
        5 -> "May"
        6 -> "Jun"
        7 -> "Jul"
        8 -> "Aug"
        9 -> "Sep"
        10 -> "Oct"
        11 -> "Nov"
        12 -> "Dec"
        _ -> "DateTime.month never returns anything outside the above range."
