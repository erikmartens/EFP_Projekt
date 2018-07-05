module Data.ChatbotHistory exposing (ChatbotHistoryEntry, decode, toChatMessage)

-- Core Modules

import Json.Decode
import Json.Decode exposing (Decoder, string, int, float, maybe)


-- Library Modules

import Json.Decode.Pipeline exposing (decode, required, optional)


-- Project Modules

import Data.ChatMessage


{-
   Represents a chat bot history entry.
-}


type alias ChatbotHistoryEntry =
    { userId : String
    , userChatMessage : String
    , answer : String
    , intentName : String
    , timeStamp : Float
    }


decode : Json.Decode.Decoder (List ChatbotHistoryEntry)
decode =
    Json.Decode.list decodeEntry


{-
   Decodes the necessary json body for the query rest request.
-}


decodeEntry : Json.Decode.Decoder ChatbotHistoryEntry
decodeEntry =
    Json.Decode.Pipeline.decode ChatbotHistoryEntry
        |> required "userId" string
        |> required "userChatMessage" string
        |> required "answer" string
        |> required "intent" string
        |> required "timeStamp" float


toChatMessage : List ChatbotHistoryEntry -> List Data.ChatMessage.ChatMessage
toChatMessage entries =
    entries
        |> List.foldl (\entry formerEntries -> (convertToChatMessage entry) :: formerEntries) []
        |> List.reverse
        |> List.concat


convertToChatMessage : ChatbotHistoryEntry -> List Data.ChatMessage.ChatMessage
convertToChatMessage { userChatMessage, answer } =
    [ { owner = "User", message = userChatMessage }
    , { owner = "Chatbot", message = answer } ]
