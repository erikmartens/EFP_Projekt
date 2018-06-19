module Main exposing (..)

import Navigation
import Route

import Html exposing (Html)
import Html.Events
import Html.Attributes
import Json.Decode exposing (Decoder, string, int, float, maybe)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode
import Http
import RemoteData
import Task
import Dom.Scroll
import Time
import Regex
import Array

-- MODEL


type alias ChatMessage =
    { owner : String
    , message : String
    }


type alias ChatbotMessage =
    { statusCode : Int
    , userId : Maybe String
    , userChatMessage : String
    , botChatMessage : String
    , intentName : String
    , timeStamp : Float
    }


type alias Model =
    { messages : List ChatMessage
    , input : String
    , userId : Maybe String
    , route: Route.Route
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            location
                |> Route.fromLocation
                |> Maybe.withDefault (Route.Home Nothing)

        (Route.Home userId) =
            route
    in
        ( { messages = [], input = "", userId = userId, route = route }
        , Cmd.none
        )


chatbotMessageDecoder : Decoder ChatbotMessage
chatbotMessageDecoder =
    decode ChatbotMessage
        |> required "statusCode" int
        |> optional "userId" (maybe string) Nothing
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
    | UrlChange (Maybe Route.Route)


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


encodeUserChatMessageToJson : String -> Maybe String -> Time.Time -> Json.Encode.Value
encodeUserChatMessageToJson input userId time =
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


fetchChatbotMessage : Maybe String -> String -> Time.Time -> Cmd Msg
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
                |> List.map viewChatMessage
            )
            |> Html.map never
        , Html.div [ Html.Attributes.class "chatbot-chat-input-container" ]
            [ Html.input [ onEnter UserMessage, Html.Events.onInput InputAdd, Html.Attributes.value input, Html.Attributes.class "chatbot-chat-input" ] [] ]
        ]


{-
    Displays the view container of a chat message. The alignment is implemented via CSS.
-}
viewChatMessage : ChatMessage -> Html Never
viewChatMessage { message, owner } =
    Html.div [ Html.Attributes.classList [ ( "chatbot-chat-message-container", True ), ( "user-message-container", owner == "User" ), ( "chatbot-message-container", owner == "Chatbot" ) ] ]
        [ Html.div [ Html.Attributes.classList [ ( "chat-message", True ), ( "user-message", owner == "User" ), ( "chatbot-message", owner == "Chatbot" ) ] ]
            [ parseChatMessage message
            ]
        ]


{-
    The faq answers are strings. All line breaks will be converted to a <br> tag.
-}
parseChatMessage : String -> Html.Html Never
parseChatMessage answer =
    let
        t_ =
            answer
                |> String.split "\n"
                |> List.filter (\lineContent -> String.length lineContent > 0)
                |> List.map (\text_ -> parseLinks text_)
                |> List.intersperse (Html.br [] [])
    in
        Html.div [] t_


{-
    All links are formatted as [title](link). They will be converted into <a href=url>title</a>.
-}
parseLinks : String -> Html.Html Never
parseLinks answer =
    let
        textElements =
            answer
                |> Regex.replace Regex.All (Regex.regex "\\[.*?\\]\\(.*?\\)") (\_ -> "_||_")
                |> String.split "_||_"
                |> List.map (\text_ -> Html.text text_)

        linkElements =
            answer
                |> Regex.find Regex.All (Regex.regex "\\[(.*?)\\]\\((.*?)\\)")
                |> List.map parseLink
                |> Array.fromList

        linkTextCombined =
            textElements
                |> List.indexedMap (,)
                |> List.foldl (\( index, textElement ) combinedElements -> (Maybe.withDefault (Html.br [] []) (Array.get index linkElements)) :: textElement :: combinedElements) []
                |> List.reverse
    in
        Html.p [] linkTextCombined


{-
    Splits a [title](link) regex match into <a href=url>title</a>
-}
parseLink : Regex.Match -> Html.Html Never
parseLink { match, submatches } =
    let
        title =
            submatches
                |> List.head
                |> join
                |> Maybe.withDefault ""

        url =
            submatches
                |> List.reverse
                |> List.head
                |> join
                |> Maybe.withDefault ""
    in
        Html.a [ Html.Attributes.href url ] [ Html.text title ]


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


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> UrlChange)
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
