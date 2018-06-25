module Data.ChatMessage exposing (ChatMessage)

{-
   The chat message models a displayed conversation between the user and the chat bot.
-}


type alias ChatMessage =
    { owner : String
    , message : String
    }
