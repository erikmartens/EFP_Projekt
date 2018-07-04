module Main exposing (..)

-- Core Modules

import Navigation
import Route


-- Project Modules

import Model exposing (Model)
import Update exposing (Msg(..), update)
import View exposing (view)


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            location
                |> Route.fromLocation
                |> Maybe.withDefault (Route.Home Nothing)

        (Route.Home userId) =
            route

        initialCmd =
            case userId of
                Nothing ->
                    Cmd.none

                Just userId ->
                    Update.fetchChatbotHistory userId
    in
        ( { messages = [], input = "", userId = userId, route = route }
        , initialCmd
        )


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> UrlChange)
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
