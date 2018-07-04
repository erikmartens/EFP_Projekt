module Update exposing (Msg(..), onEnter, update, fetchChatbotHistory)

-- Core Modules

import Html
import Html.Events
import Json.Decode
import Task
import Time
import Http


-- Library Modules

import RemoteData
import Dom.Scroll


-- Project Modules

import Model exposing (Model)
import Route
import Data.ChatbotMessage
import Data.ChatbotHistory


type Msg
    = UserMessage
    | FetchChatbotMessage (RemoteData.WebData Data.ChatbotMessage.ChatbotMessage)
    | FetchChatbotHistory (RemoteData.WebData (List Data.ChatbotHistory.ChatbotHistoryEntry))
    | InputAdd String
    | NoOp
    | CurrentDateForChatRequest Time.Time
    | UrlChange (Maybe Route.Route)



{-
   This handler reacts on pressing the enter key.
-}


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        Html.Events.on "keydown" (Json.Decode.andThen isEnter Html.Events.keyCode)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserMessage ->
            let
                input =
                    model.input
            in
                ( { model | messages = (List.append model.messages [ { owner = "User", message = input } ]) }, Task.perform CurrentDateForChatRequest Time.now )

        FetchChatbotMessage response ->
            case response of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success chatbotMessage ->
                    ( { model | messages = (List.append model.messages [ { owner = "Chatbot", message = chatbotMessage.botChatMessage } ]) }, Task.attempt (\_ -> NoOp) (Dom.Scroll.toBottom "chatbot-chat-container") )

                RemoteData.Failure error ->
                    ( model, Cmd.none )

        InputAdd inputStr ->
            ( { model | input = inputStr }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        CurrentDateForChatRequest time ->
            let
                userMessage =
                    model.input
            in
                ( { model | input = "" }, fetchChatbotMessage model.userId userMessage time )

        UrlChange route ->
            let
                updatedRoute =
                    case route of
                        Nothing ->
                            Route.Home Nothing

                        Just route ->
                            route
            in
                ( { model | route = updatedRoute }, Cmd.none )

        FetchChatbotHistory response ->
                    case response of
                        RemoteData.NotAsked ->
                            ( model, Cmd.none )

                        RemoteData.Loading ->
                            ( model, Cmd.none )

                        RemoteData.Success history ->
                            ( { model | messages = Data.ChatbotHistory.toChatMessage history }, Task.attempt (\_ -> NoOp) (Dom.Scroll.toBottom "chatbot-chat-container") )

                        RemoteData.Failure error ->
                            ( model, Cmd.none )



{-
   Fetches the chat bot answer with a backend rest request.
   TODO: Maybe move this into Data.ChatbotMessage?
-}


fetchChatbotMessage : Maybe String -> String -> Time.Time -> Cmd Msg
fetchChatbotMessage userId userMessage timestamp =
    Http.post
        "/api/query"
        (Http.jsonBody (Data.ChatbotMessage.encode userMessage userId timestamp))
        Data.ChatbotMessage.decode
        |> RemoteData.sendRequest
        |> Cmd.map FetchChatbotMessage


fetchChatbotHistory : String -> Cmd Msg
fetchChatbotHistory userId =
    Http.get
        ("/api/chat?userId=" ++ userId)
        Data.ChatbotHistory.decode
        |> RemoteData.sendRequest
        |> Cmd.map FetchChatbotHistory