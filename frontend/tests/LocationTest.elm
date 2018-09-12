module LocationTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Json.Decode

import Domain.Location as Location


suite : Test
suite =
    describe "Location module tests"
        [ test "Decode a API response" <|
            \_ -> 
                let
                    json =
                        """
                        {
                            "ip": "134.255.104.22",
                            "type": "ipv4",
                            "continent_code": "EU",
                            "continent_name": "Europe",
                            "country_code": "HU",
                            "country_name": "Hungary",
                            "region_code": "BU",
                            "region_name": "Budapest",
                            "city": "Budapest",
                            "zip": "1222",
                            "latitude": 47.5,
                            "longitude": 19.0833,
                            "location": {
                                "geoname_id": 3054643,
                                "capital": "Budapest",
                                "languages": [
                                    {
                                        "code": "hu",
                                        "name": "Hungarian",
                                        "native": "Magyar"
                                    }
                                ],
                                "country_flag": "http:\\/\\/assets.ipstack.com\\/flags\\/hu.svg",
                                "country_flag_emoji": "\\ud83c\\udded\\ud83c\\uddfa",
                                "country_flag_emoji_unicode": "U+1F1ED U+1F1FA",
                                "calling_code": "36",
                                "is_eu": true
                            }
                        }
                        """    
                in
                    json 
                        |> Json.Decode.decodeString Location.locationDecoder 
                        |> Expect.equal 
                            (Ok (Location.fromCoordinates 47.5 19.0833))
        ] 
