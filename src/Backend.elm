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
        ClientTyped key ->
            case ( String.uncons key, model.recentKeys ) of
                ( Just ( char, "" ), _ ) ->
                    let
                        totalTyped =
                            model.typedCharacters + 1

                        recentKeys =
                            char :: List.take 64 model.recentKeys
                    in
                    ( { model
                        | typedCharacters = totalTyped
                        , recentKeys = recentKeys
                      }
                    , Lamdera.broadcast <| TypedCharacter totalTyped (recentKeys |> List.reverse >> String.fromList)
                    )

                _ ->
                    ( model, Cmd.none )
