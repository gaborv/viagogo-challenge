module EventTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Json.Decode
import Time.DateTime as Time

import Domain.Event as Event
import Domain.Location as Location

sampleResponse =
    """
    {
        "total_items": 1,
        "page": 1,
        "page_size": 100,
        "_links": {
            "self": {
                "href": "https://api.viagogo.net/v2/categories/11881/events?page_size=100&sort=date&tagTypeId=1&page=1",
                "title": null,
                "templated": false
            }
        },
        "_embedded": {
            "items": [
                {
                    "min_ticket_price": {
                        "amount": 85.45,
                        "currency_code": "USD",
                        "display": "$85.45"
                    },
                    "number_of_tickets": 424,
                    "notes_html": "<div>Sample</div>",
                    "restrictions_html": null,
                    "affiliate_commission_tier": "Normal",
                    "id": 2570447,
                    "name": "U2",
                    "start_date": "2018-09-12T18:00:00+00:00",
                    "end_date": null,
                    "on_sale_date": "2018-01-31T10:00:00+01:00",
                    "date_confirmed": true,
                    "_links": {
                        "self": {
                            "href": "https://api.viagogo.net/v2/events/2570447?category_id=11881",
                            "title": null,
                            "templated": false
                        },
                        "event:category": {
                            "href": "https://api.viagogo.net/v2/categories/11881",
                            "title": null,
                            "templated": false
                        },
                        "event:listingconstraints": {
                            "href": "https://api.viagogo.net/v2/events/2570447/listingconstraints",
                            "title": null,
                            "templated": false
                        },
                        "event:listings": {
                            "href": "https://api.viagogo.net/v2/events/2570447/listings?category_id=11881",
                            "title": "View Tickets",
                            "templated": false
                        },
                        "event:localwebpage": {
                            "href": "http://www.viagogo.fr/Concert-Tickets/Rock-and-Pop/U2-Tickets/E-2570447",
                            "title": null,
                            "templated": false
                        },
                        "event:webpage": {
                            "href": "http://www.viagogo.com/ww/Concert-Tickets/Rock-and-Pop/U2-Tickets/E-2570447",
                            "title": null,
                            "templated": false
                        }
                    },
                    "_embedded": {
                        "venue": {
                            "id": 1023,
                            "name": "AccorHotels Arena",
                            "city": "Paris",
                            "state_province": null,
                            "latitude": 48.8385,
                            "longitude": 2.3786,
                            "_links": {
                                "self": {
                                    "href": "https://api.viagogo.net/v2/venues/1023",
                                    "title": null,
                                    "templated": false
                                }
                            },
                            "_embedded": {
                                "country": {
                                    "code": "FR",
                                    "name": "France",
                                    "_links": {
                                        "self": {
                                            "href": "https://api.viagogo.net/v2/countries/FR",
                                            "title": null,
                                            "templated": false
                                        },
                                        "country:events": {
                                            "href": "https://api.viagogo.net/v2/categories/0/events?country_code=FR",
                                            "title": null,
                                            "templated": false
                                        },
                                        "country:localwebpage": {
                                            "href": "http://www.viagogo.fr/",
                                            "title": null,
                                            "templated": false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
    """


suite : Test
suite =
    describe "Event related tests"
        [ test "Decode a API response" <|
            \_ -> 
                sampleResponse 
                    |> Json.Decode.decodeString Event.eventListDecoder
                    |> Expect.equal 
                        ( Ok
                            [ 
                                { id =2570447
                                , minimumPrice = 85.45
                                , numberOfTickets = 424
                                , startsAt = 
                                    Time.dateTime 
                                        { year = 2018
                                        , month = 9
                                        , day = 12
                                        , hour = 18
                                        , minute = 0
                                        , second = 0
                                        , millisecond = 0
                                        }
                                , listingsApiUrl = "https://api.viagogo.net/v2/events/2570447/listings?category_id=11881"
                                , listingsWebSite = "http://www.viagogo.com/ww/Concert-Tickets/Rock-and-Pop/U2-Tickets/E-2570447"
                                , venue =
                                    { name = "AccorHotels Arena"
                                    , city = "Paris"
                                    , country = "France"
                                    , location = (Location.fromCoordinates 48.8385 2.3786)
                                    }
                                }
                            ]
                        )
        ] 
