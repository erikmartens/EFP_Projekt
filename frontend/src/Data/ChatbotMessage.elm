module Data.ChatbotMessage exposing (ChatbotMessage, decode, encode)

-- Core Modules

import Json.Decode
import Json.Decode exposing (Decoder, string, int, float, maybe)
import Json.Encode
import Time


-- Library Modules

import Json.Decode.Pipeline exposing (decode, required, optional)


{-
   Represents a backend chat bot answer.
-}


type alias ChatbotMessage =
    { statusCode : Int
    , userId : Maybe String
    , userChatMessage : String
    , botChatMessage : String
    , intentName : String
    , timeStamp : Float
    }



{-
   Decodes the necessary json body for the query rest request.
-}


decode : Json.Decode.Decoder ChatbotMessage
decode =
    Json.Decode.Pipeline.decode ChatbotMessage
        |> required "statusCode" int
        |> optional "userId" (maybe string) Nothing
        |> required "userChatMessage" string
        |> required "botChatMessage" string
        |> required "intentName" string
        |> required "timeStamp" float



{-
   Encodes the backend query response into the corresponding elm model.
-}


encode : String -> Maybe String -> Time.Time -> Json.Encode.Value
encode input userId time =
    let
        userIdEncoder =
            case userId of
                Nothing ->
                    Json.Encode.null

                Just userId ->
                    Json.Encode.string userId
    in
        Json.Encode.object
            [ ( "userId", userIdEncoder )
            , ( "userChatMessage", Json.Encode.string input )
            , ( "timeStamp", Json.Encode.float time )
            ]
