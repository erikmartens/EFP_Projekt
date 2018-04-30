module Main exposing (..)


import Html exposing (Html)
import Html.Events
import Html.Attributes
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Http
import RemoteData
import Task
import Dom.Scroll

-- MODEL


type alias ChatMessage =
    { owner : String
    , message : String
    }


type alias ElizaMessage =
    { message : String
    }


type alias Model =
    { messages : List ChatMessage
    , input : String
    }


init : ( Model, Cmd Msg )
init =
    ( { messages = [], input = "" }
    , Cmd.none
    )


elizaMessageDecoder : Decoder ElizaMessage
elizaMessageDecoder =
    decode ElizaMessage
        |> required "message" string


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
    | FetchElizaMessage (RemoteData.WebData ElizaMessage)
    | InputAdd String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
    case msg of
        UserMessage ->
            let
                input =
                    model.input
            in
            ( { model | messages = (List.append model.messages [ { owner = "User", message = input } ]), input = "" }, fetchElizaMessage input )

        FetchElizaMessage response ->
            case response of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Success elizaMessage ->
                    ( { model | messages = (List.append model.messages [ { owner = "Eliza", message = elizaMessage.message } ]) }, Task.attempt (\_ -> NoOp) (Dom.Scroll.toBottom "eliza-chat-container") )

                RemoteData.Failure error ->
                    ( model, Cmd.none )

        InputAdd inputStr ->
            ( { model | input = inputStr }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


fetchElizaMessage : String -> Cmd Msg
fetchElizaMessage userMessage =
    Http.get
        ("http://localhost:5000/query"
            ++ "?q="
            ++ userMessage
        )
        elizaMessageDecoder
        |> RemoteData.sendRequest
        |> Cmd.map FetchElizaMessage



-- VIEW


view : Model -> Html Msg
view { messages, input } =
    Html.div [ Html.Attributes.class "eliza-chat-outer-container" ]
        [ Html.div [ Html.Attributes.class "eliza-chat-header-container" ]
            [ Html.text "Send messages to Eliza" ]
        , Html.div [ Html.Attributes.class "eliza-chat-container", Html.Attributes.id "eliza-chat-container" ]
            (messages
                |> List.map viewChatMessage)
                |> Html.map never
        , Html.div [ Html.Attributes.class "eliza-chat-input-container" ]
            [ Html.input [ onEnter UserMessage, Html.Events.onInput InputAdd, Html.Attributes.value input, Html.Attributes.class "eliza-chat-input" ] [ ] ]
        ]



viewChatMessage : ChatMessage -> Html Never
viewChatMessage { message, owner } =
    Html.div [ Html.Attributes.classList [("eliza-chat-message-container", True), ("user-message-container", owner == "User"), ("eliza-message-container", owner == "Eliza")] ]
        [ Html.div [ Html.Attributes.classList [("chat-message", True), ("user-message", owner == "User"), ("eliza-message", owner == "Eliza")] ]
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