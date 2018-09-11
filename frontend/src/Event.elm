module Event exposing
    ( Event
    , Venue
    , eventListDecoder
    , getEvents
    )

import AuthorizedRequest
import Http
import Json.Decode as Json
import Location exposing (Location)
import Time.DateTime as Time
import Time.Iso8601


type alias Event =
    { minimumPrice : Float
    , numberOfTickets : Int
    , startsAt : Time.DateTime
    , listingsUrl : String
    , venue : Venue
    }


eventDecoder : Json.Decoder Event
eventDecoder =
    Json.map5 Event
        (Json.at [ "min_ticket_price", "amount" ] Json.float)
        (Json.field "number_of_tickets" Json.int)
        (Json.field "start_date" iso8601Decoder)
        (Json.at [ "_links", "event:listings", "href" ] Json.string)
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
