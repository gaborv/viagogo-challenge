module Domain.AuthorizedRequest exposing
    ( get
    , getWithCurrency
    )

import Http
import Json.Decode as Json


autorizationHeader accessToken =
    Http.header
        "Authorization"
        ("Bearer " ++ accessToken)


{-| Simple `GET` request with an `Authorization` header as required by [OAuth2][https://tools.ietf.org/html/rfc6750]:

    Bearer accessToken

-}
get : String -> String -> Json.Decoder a -> Http.Request a
get accessToken url decoder =
    Http.request
        { method = "GET"
        , headers = [ accessToken |> autorizationHeader ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


getWithCurrency : String -> String -> String -> Json.Decoder a -> Http.Request a
getWithCurrency accessToken currency url decoder =
    Http.request
        { method = "GET"
        , headers =
            [ accessToken |> autorizationHeader
            , Http.header "Accept-Currency" currency
            ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
