module View exposing (view)

-- Core Modules

import Array
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Regex


-- Project Modules

import Model exposing (Model)
import Update exposing (Msg(..))
import Util
import Data.ChatMessage


-- VIEW


view : Model -> Html Msg
view { messages, input } =
    Html.div [ Html.Attributes.class "chatbot-chat-outer-container" ]
        [ Html.div [ Html.Attributes.class "chatbot-chat-header-container" ]
            [ Html.text "Praxissemester F.A.Q. Chatbot" ]
        , Html.div [ Html.Attributes.class "chatbot-chat-container", Html.Attributes.id "chatbot-chat-container" ]
            (messages
                |> List.map viewChatMessage
            )
            |> Html.map never
        , Html.div [ Html.Attributes.class "chatbot-chat-input-container" ]
            [ Html.input [ Update.onEnter UserMessage, Html.Events.onInput InputAdd, Html.Attributes.value input, Html.Attributes.class "chatbot-chat-input" ] []
            , Html.div [ Html.Attributes.class "chatbot-chat-input-send-container", Html.Events.onClick UserMessage ]
                [ Html.text "Send" ]
            ]
        ]



{-
   Displays the view container of a chat message. The alignment is implemented via CSS.
-}


viewChatMessage : Data.ChatMessage.ChatMessage -> Html Never
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
                |> Util.join
                |> Maybe.withDefault ""

        url =
            submatches
                |> List.reverse
                |> List.head
                |> Util.join
                |> Maybe.withDefault ""
    in
        Html.a [ Html.Attributes.href url, Html.Attributes.target "_blank" ] [ Html.text title ]
