module Route exposing (Route(..), route, fromLocation)

import UrlParser as Url exposing ((<?>), s, stringParam, parsePath)
import Navigation


type Route
    = Home (Maybe String)


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home (s "chat" <?> stringParam "userId")
        ]


fromLocation : Navigation.Location -> Maybe Route
fromLocation location =
    parsePath route location
