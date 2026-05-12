module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Events as BrowserEvents
import Browser.Navigation as Nav
import Html
import Html.Attributes as Attr
import Json.Decode as Json
import Lamdera
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app : { init : Lamdera.Url -> Nav.Key -> ( Model, Cmd FrontendMsg ), view : Model -> Browser.Document FrontendMsg, update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg ), updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg ), subscriptions : Model -> Sub FrontendMsg, onUrlRequest : UrlRequest -> FrontendMsg, onUrlChange : Url.Url -> FrontendMsg }
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = always onKeyPressSubscription
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init _ key =
    ( { key = key
      , message = "Start typing and behold the bliss"
      , recentKeys = []
      }
    , Cmd.none
    )



-- update


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged _ ->
            ( model, Cmd.none )

        KeyPressed key ->
            case String.uncons key of
                Just ( 'E', "nter" ) ->
                    ( model, Lamdera.sendToBackend <| ClientTyped '↵' )

                Just ( char, "" ) ->
                    ( model, Lamdera.sendToBackend <| ClientTyped char )

                _ ->
                    ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        TypedCharacter total recentKeys ->
            let
                message =
                    String.fromInt total ++ " characters typed (globally!) since the initial release of this app!"
            in
            ( { model | message = message, recentKeys = recentKeys }, Cmd.none )



--- view


title : String
title =
    "GreenType – That Mechanical Keyboard You've Always Wanted"


view : Model -> Browser.Document FrontendMsg
view model =
    { title = title
    , body =
        [ Html.div
            [ Attr.class "pt-32"
            , Attr.class "font-mono text-center"
            ]
            [ Html.h1
                [ Attr.class "px-[8vw] text-[4vw]" ]
                [ Html.text title ]
            , Html.p
                [ Attr.class "pt-10" ]
                [ Html.text model.message ]
            , Html.div
                [ Attr.class "flex flex-row-reverse justify-around"
                , Attr.class "px-[8vw] pt-4"
                , Attr.class "text-[8vw]"
                ]
                (model.recentKeys
                    |> List.indexedMap
                        (\i char ->
                            let
                                opacity =
                                    (1.0
                                        - (toFloat i * 0.03)
                                    )
                                        |> String.fromFloat
                            in
                            Html.div
                                [ Attr.class "w-4"
                                , Attr.style "opacity" opacity
                                ]
                                [ Html.text <| String.fromChar char ]
                        )
                )
            , Html.node "thock-trigger" [ Attr.attribute "trigger" model.message ] []
            ]
        ]
    }



-- subscriptions


onKeyPressSubscription : Sub FrontendMsg
onKeyPressSubscription =
    BrowserEvents.onKeyPress keyCodeDecoder


keyCodeDecoder : Json.Decoder FrontendMsg
keyCodeDecoder =
    Json.field "key" Json.string
        |> Json.map KeyPressed
