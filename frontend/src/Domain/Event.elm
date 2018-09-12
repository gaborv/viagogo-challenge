module Domain.Event exposing
    ( Event
    , Venue
    , eventListDecoder
    , getEvents
    , viewEvent
    )

import Domain.AuthorizedRequest as AuthorizedRequest
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Json
import Domain.Location as Location exposing (Location)
import Time.DateTime as Time
import Time.Iso8601


type alias Event =
    { id : Int
    , minimumPrice : Float
    , numberOfTickets : Int
    , startsAt : Time.DateTime
    , listingsApiUrl : String
    , listingsWebSite : String
    , venue : Venue
    }


eventDecoder : Json.Decoder Event
eventDecoder =
    Json.map7 Event
        (Json.field "id" Json.int)
        (Json.at [ "min_ticket_price", "amount" ] Json.float)
        (Json.field "number_of_tickets" Json.int)
        (Json.field "start_date" iso8601Decoder)
        (Json.at [ "_links", "event:listings", "href" ] Json.string)
        (Json.at [ "_links", "event:localwebpage", "href" ] Json.string)
        (Json.at [ "_embedded", "venue" ] venueDecoder)


iso8601Decoder =
    Json.string
        |> Json.andThen
            (Time.Iso8601.toDateTime
                >> Result.map Json.succeed
                >> Result.withDefault (Json.fail "Wrong date format on event.")
            )


type alias Venue =
    { name : String
    , city : String
    , country : String
    , location : Location
    }


venueDecoder : Json.Decoder Venue
venueDecoder =
    Json.map4 Venue
        (Json.field "name" Json.string)
        (Json.field "city" Json.string)
        (Json.at [ "_embedded", "country", "name" ] Json.string)
        Location.locationDecoder


eventsUrl : Int -> String
eventsUrl categoryId =
    "https://api.viagogo.net/v2/categories/"
        ++ String.fromInt categoryId
        ++ "/events?page_size=1000&sort=date"


{-| Query Viagogo's API to retrieve the first 1000 events for a given category.
In practice this means that it will retrieve all events for (at least) the next 12 months for a given artist.

Currently the most concerts performed during a single year is 727 (<http://www.guinnessworldrecords.com/world-records/24992-most-concerts-performed-in-one-year>)
However a more realistic upper estimate for mainstream bands (based on top selling tours) should be in the 100-200 range.

My upper estimate download size for the data set is about 35KB for the mainstream case and about 150KB for the extreme case.

-}
getEvents : Int -> String -> Http.Request (List Event)
getEvents categoryId accessToken =
    AuthorizedRequest.get
        accessToken
        (eventsUrl categoryId)
        eventListDecoder


eventListDecoder =
    Json.at [ "_embedded", "items" ] (Json.list eventDecoder)



---------------
-- View


viewEvent : Bool -> Event -> Html msg
viewEvent isLowestPrice event =
    let
        header =
            if isLowestPrice then 
                div [ class "card-header bg-success text-white" ]
                    [ span [ class "badge badge-warning" ] [ text "Cheapest!" ]
                    , text " from "
                    , span [ class "font-weight-bold" ]
                        [ text "$"
                        , text (event.minimumPrice |> String.fromFloat)
                        ]
                    ]
              else 
                div [ class "card-header" ]
                    [ text "Tickets starting from "
                    , span [ class "font-weight-bold" ]
                        [ text "$"
                        , text (event.minimumPrice |> String.fromFloat)
                        ]
                    ]
    in
        div [ class "card mt-1 mb-3 shadow-sm" ]
            [ header
            , div [ class "card-body" ]
                [ h4 [ class "card-title" ]
                    [ text (event.startsAt |> dateToString) ]
                , h6 [ class "card-subtitle mb-2 text-muted" ]
                    [ text (event.startsAt |> time24h) ]
                , p [ class "card-text" ]
                    [ text event.venue.name
                    , text ", "
                    , text event.venue.city
                    , text ", "
                    , text event.venue.country
                    ]
                , a [ href event.listingsWebSite, class "btn btn-success" ]
                    [ text "Buy tickets!" ]
                ]
            ]


time24h : Time.DateTime -> String
time24h time =
    let
        hour =
            time |> Time.hour |> String.fromInt

        minute =
            if (time |> Time.minute) < 10 then
                "0" ++ (time |> Time.minute |> String.fromInt)

            else
                time |> Time.minute |> String.fromInt
    in
    hour ++ ":" ++ minute


dateToString : Time.DateTime -> String
dateToString date =
    (date |> monthName) ++ " " ++ (date |> Time.day |> String.fromInt) ++ ", " ++ (date |> Time.year |> String.fromInt)


monthName : Time.DateTime -> String
monthName monthSeq =
    case monthSeq |> Time.month of
        1 ->
            "January"

        2 ->
            "February"

        3 ->
            "March"

        4 ->
            "April"

        5 ->
            "May"

        6 ->
            "June"

        7 ->
            "July"

        8 ->
            "August"

        9 ->
            "September"

        10 ->
            "October"

        11 ->
            "November"

        12 ->
            "December"

        _ ->
            "DateTime.month never returns anything outside the above range."
