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
      , lastKey = Nothing
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
            ( model, Lamdera.sendToBackend <| ClientTyped key )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        TypedCharacter total char ->
            let
                message =
                    String.fromInt total ++ " characters typed (globally!) in this version!"
            in
            ( { model | message = message, lastKey = Just char }, Cmd.none )



--- view


title : String
title =
    "GreenType – That Mechanical Keyboard You've Always Wanted"


view : Model -> Browser.Document FrontendMsg
view model =
    { title = title
    , body =
        [ Html.div
            [ Attr.style "text-align" "center"
            , Attr.style "padding-top" "8rem"
            , Attr.style "font-family" "monospace"
            ]
            [ Html.h1
                [ Attr.style "padding" "0 8vmin"
                , Attr.style "font-size" "4vmin"
                ]
                [ Html.text title ]
            , Html.p
                [ Attr.style "padding-top" "40px"
                ]
                [ Html.text model.message ]
            , case model.lastKey of
                Just key ->
                    Html.div
                        [ Attr.style "font-size" "6vw"
                        , Attr.style "overflow-wrap" "anywhere"
                        , Attr.style "hyphens" "auto"
                        ]
                        [ Html.text key
                        , Html.node "thock-trigger" [ Attr.attribute "trigger" model.message ] []
                        ]

                Nothing ->
                    Html.text ""
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
        |> Json.map (String.replace "Enter" "↵")
        |> Json.map (String.replace " " "_")
        |> Json.map KeyPressed
