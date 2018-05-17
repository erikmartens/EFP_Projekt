module Main exposing (..)


import Html exposing (Html)
import Html.Events
import Html.Attributes
import Json.Decode exposing (Decoder, string, int, float)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Http
import RemoteData
import Task
import Dom.Scroll
import Time

-- MODEL


type alias ChatMessage =
    { owner : String
    , message : String
    }


type alias ChatbotMessage =
    { statusCode : Int
    , userId: String
    , userChatMessage: String
    , botChatMessage: String
    , intentName: String
    , timeStamp: Float
    }


type alias Model =
    { messages : List ChatMessage
    , input : String
    , userId : String
    }


init : ( Model, Cmd Msg )
init =
    ( { messages = [], input = "", userId = "abc123" }
    , Cmd.none
    )


chatbotMessageDecoder : Decoder ChatbotMessage
chatbotMessageDecoder =
    decode ChatbotMessage
        |> required "statusCode" int
        |> required "userId" string
        |> required "userChatMessage" string
        |> required "botChatMessage" string
        |> required "intentName" string
        |> required "timeStamp" float


-- UPDATE


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


type Msg
    = UserMessage
    | FetchChatbotMessage (RemoteData.WebData ChatbotMessage)
    | InputAdd String
    | NoOp
    | CurrentDateForChatRequest Time.Time


update : Msg -> Model -> ( Model, Cmd Msg)
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
                userMessage = model.input
            in
                (  { model | input = "" }, fetchChatbotMessage model.userId userMessage time )


encodeUserChatMessageToJson : String -> String -> Time.Time -> Json.Encode.Value
encodeUserChatMessageToJson input userId time =
    Json.Encode.object
        [ ("userId", Json.Encode.string userId)
        , ("userChatMessage", Json.Encode.string input)
        , ("timeStamp", Json.Encode.float time)
        ]

fetchChatbotMessage : String -> String -> Time.Time -> Cmd Msg
fetchChatbotMessage userId userMessage timestamp =
    Http.post
        "/api/query"
        (Http.jsonBody (encodeUserChatMessageToJson userMessage userId timestamp))
        chatbotMessageDecoder
            |> RemoteData.sendRequest
            |> Cmd.map FetchChatbotMessage



-- VIEW


view : Model -> Html Msg
view { messages, input } =
    Html.div [ Html.Attributes.class "chatbot-chat-outer-container" ]
        [ Html.div [ Html.Attributes.class "chatbot-chat-header-container" ]
            [ Html.text "Praxissemster F.A.Q. Chatbot" ]
        , Html.div [ Html.Attributes.class "chatbot-chat-container", Html.Attributes.id "chatbot-chat-container" ]
            (messages
                |> List.map viewChatMessage)
                |> Html.map never
        , Html.div [ Html.Attributes.class "chatbot-chat-input-container" ]
            [ Html.input [ onEnter UserMessage, Html.Events.onInput InputAdd, Html.Attributes.value input, Html.Attributes.class "chatbot-chat-input" ] [ ] ]
        ]



viewChatMessage : ChatMessage -> Html Never
viewChatMessage { message, owner } =
    Html.div [ Html.Attributes.classList [("chatbot-chat-message-container", True), ("user-message-container", owner == "User"), ("chatbot-message-container", owner == "Chatbot")] ]
        [ Html.div [ Html.Attributes.classList [("chat-message", True), ("user-message", owner == "User"), ("chatbot-message", owner == "Chatbot")] ]
            [ Html.text (message)
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }