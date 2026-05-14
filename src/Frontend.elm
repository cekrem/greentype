module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Events as BrowserEvents
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
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
      , data = Nothing
      }
    , Lamdera.sendToBackend RequestedData
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

                Just ( ' ', "" ) ->
                    ( model, Lamdera.sendToBackend <| ClientTyped '_' )

                Just ( char, "" ) ->
                    ( model, Lamdera.sendToBackend <| ClientTyped char )

                _ ->
                    ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        DataUpdated total recentKeys ->
            let
                data =
                    Just
                        { message =
                            String.fromInt total ++ " characters typed (globally!) since the initial release of this app!"
                        , recentKeys = recentKeys
                        }
            in
            ( { model | data = data }, Cmd.none )



--- view


title : String
title =
    "GreenType – That Mechanical Keyboard You've Always Wanted"


view : Model -> Browser.Document FrontendMsg
view model =
    { title = title
    , body =
        case model.data of
            Just { recentKeys, message } ->
                [ Html.div
                    [ Attr.class "flex flex-col justify-center h-screen"
                    , Attr.class "font-mono text-center"
                    ]
                    [ Html.h1
                        [ Attr.class "px-[8vw] text-[4vw]" ]
                        [ Html.text title ]
                    , Html.p
                        [ Attr.class "pt-10" ]
                        [ Html.text message ]
                    , Html.div
                        [ Attr.class "flex flex-row-reverse justify-around items-center"
                        , Attr.class "w-2/3 h-48"
                        , Attr.class "text-[6vw]"
                        ]
                        (recentKeys
                            |> List.indexedMap
                                (\i char ->
                                    let
                                        faded =
                                            (1.0
                                                - (toFloat i * 0.04)
                                            )
                                                |> String.fromFloat
                                    in
                                    Html.div
                                        [ Attr.style "opacity" faded
                                        , Attr.style "font-size" (faded ++ "em")
                                        ]
                                        [ Html.text <| String.fromChar char ]
                                )
                        )
                    , thockTrigger recentKeys
                    ]
                , Html.footer
                    [ Attr.class "fixed p-2 bottom-0 text-center w-full"
                    ]
                    [ Html.a [ Attr.href "https://cekrem.github.io" ] [ Html.text "made by cekrem" ] ]
                , mobileKeyboard
                ]

            Nothing ->
                []
    }


mobileKeyboard : Html FrontendMsg
mobileKeyboard =
    Html.textarea
        [ Attr.class "fixed top-0 bottom-0 left-0 right-0 opacity-0 md:hidden"
        , Attr.autofocus True
        , Events.onInput KeyPressed
        ]
        []


thockTrigger : List Char -> Html.Html msg
thockTrigger recentKeys =
    case recentKeys of
        [] ->
            Html.text ""

        lastChar :: rest ->
            let
                code =
                    lastChar |> Char.toCode |> String.fromInt

                seq =
                    rest |> String.fromList
            in
            Html.node "thock-trigger"
                [ Attr.attribute "code" code
                , Attr.attribute "seq" seq
                ]
                []



-- subscriptions


onKeyPressSubscription : Sub FrontendMsg
onKeyPressSubscription =
    BrowserEvents.onKeyDown keyCodeDecoder


keyCodeDecoder : Json.Decoder FrontendMsg
keyCodeDecoder =
    Json.field "key" Json.string
        |> Json.map KeyPressed
