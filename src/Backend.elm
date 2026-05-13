module Backend exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)


type alias Model =
    BackendModel


app : { init : ( Model, Cmd BackendMsg ), update : BackendMsg -> Model -> ( Model, Cmd BackendMsg ), updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg ), subscriptions : Model -> Sub BackendMsg }
app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { typedCharacters = 0
      , recentKeys = []
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        ClientTyped char ->
            let
                typedCharacters =
                    model.typedCharacters + 1

                recentKeys =
                    char :: List.take 32 model.recentKeys
            in
            broadcastData
                { model
                    | typedCharacters = typedCharacters
                    , recentKeys = recentKeys
                }

        RequestedData ->
            broadcastData model


broadcastData : Model -> ( Model, Cmd backendMsg )
broadcastData model =
    ( model, Lamdera.broadcast <| DataUpdated model.typedCharacters model.recentKeys )
