module Util exposing (join)

{-
   Combines a nested maybe.
-}


join : Maybe (Maybe a) -> Maybe a
join maybe =
    case maybe of
        Just maybe ->
            maybe

        Nothing ->
            Nothing
