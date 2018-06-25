module Model exposing (Model)

-- Project Modules

import Data.ChatMessage
import Route


{-
   The main model for the whole app.
-}


type alias Model =
    { messages : List Data.ChatMessage.ChatMessage
    , input : String
    , userId : Maybe String
    , route : Route.Route -- TODO: This is not really necessary here as we don't use it anywhere. Maybe remove it?
    }
