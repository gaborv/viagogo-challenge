module Domain.Location exposing 
    ( Location, locationDecoder, fromCoordinates
    , Distance, distanceFrom, inMeter, inKm
    )

import Json.Decode as Json


type Location = 
    Location
        { longitude : Float
        , latitude : Float
        }


locationDecoder : Json.Decoder Location
locationDecoder =
    Json.map2 fromCoordinates
        (Json.field "latitude" Json.float)
        (Json.field "longitude" Json.float)


fromCoordinates : Float -> Float -> Location
fromCoordinates latitude longitude =
    Location
        { latitude = latitude
        , longitude = longitude
        }


type Distance =
    Distance Float


inMeter : Distance -> Float
inMeter (Distance dm) =
    dm


inKm : Distance -> Float
inKm (Distance dm) =
    dm / 1000


{-| Calculate great-circle distance between two coordinates using the 'haversine' formula
as [described here][https://www.movable-type.co.uk/scripts/latlong.html].
-}
distanceFrom : Location -> Location -> Distance
distanceFrom (Location l1) (Location l2) =
    let
        radiusOfEarth = 6371008 -- radius of the earth in meter

        dLat = 
            (l2.latitude - l1.latitude) |> degrees
        
        dLon = 
            (l2.longitude - l1.longitude) |> degrees

        a = 
            (sin (dLat/2))^2 +
            (cos (l1.latitude |> degrees)) * (cos (l2.latitude |> degrees)) * (sin (dLon/2))^2

        c =     -- angular distance in radians
            2 * atan2 (sqrt a) (sqrt (1-a))
    in
        Distance (radiusOfEarth * c)

