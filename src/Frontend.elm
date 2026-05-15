module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events as BrowserEvents
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Json
import Lamdera
import Task
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



-- init


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init _ key =
    ( { key = key
      , keyboard = "cherrymx-blue-abs"
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

        KeyboardChanged keyboard ->
            ( { model | keyboard = keyboard }, Task.attempt (always BlurredSelect) (Browser.Dom.blur "select") )

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

        BlurredSelect ->
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
                    [ Attr.class "flex flex-col md:justify-center"
                    , Attr.class "h-dvh"
                    , Attr.class "gap-8"
                    , Attr.class "p-4"
                    , Attr.class "font-mono text-center"
                    ]
                    [ Html.h1
                        [ Attr.class "px-[8vw] text-[4vw]" ]
                        [ Html.text title ]
                    , viewKeyboardSelector model.keyboard
                    , Html.p [] [ Html.text message ]
                    , viewRecentKeys recentKeys
                    ]
                , viewFooter
                , viewMobileKeyboardTextarea
                , thockTrigger model.keyboard recentKeys
                ]

            Nothing ->
                []
    }


keyboards : List String
keyboards =
    [ "cherrymx-blue-abs"
    , "cherrymx-blue-pbt"
    , "cherrymx-black-abs"
    , "cherrymx-black-pbt"
    , "cherrymx-brown-abs"
    , "cherrymx-brown-pbt"
    , "cherrymx-red-abs"
    , "cherrymx-red-pbt"
    ]


viewKeyboardSelector : String -> Html FrontendMsg
viewKeyboardSelector selected =
    Html.select
        [ Attr.id "select"
        , Attr.class "z-10"
        , Attr.class "w-auto"
        , Attr.class "self-center"
        , Attr.class "p-2"
        , Attr.class "text-xl"
        , Attr.class "bg-gray-100"
        , Attr.class "rounded"
        , Attr.class "outline-4 outline-[#0F0]"
        , Attr.class "appearance-none"
        , Events.onInput KeyboardChanged
        ]
        (keyboards
            |> List.map
                (\name ->
                    Html.option [ Attr.selected <| name == selected ] [ Html.text name ]
                )
        )


viewRecentKeys : List Char -> Html msg
viewRecentKeys recentKeys =
    Html.div
        [ Attr.class "flex flex-row-reverse items-center justify-around"
        , Attr.class "h-[6vw] w-2/3"
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


viewFooter : Html msg
viewFooter =
    Html.footer
        [ Attr.class "fixed bottom-0 z-10"
        , Attr.class "w-full"
        , Attr.class "p-2"
        , Attr.class "text-center"
        ]
        [ Html.a [ Attr.href "https://cekrem.github.io" ] [ Html.text "made by cekrem" ]
        , Html.text " · sounds by "
        , Html.a [ Attr.href "https://mechvibes.com" ] [ Html.text "mechvibes" ]
        ]


viewMobileKeyboardTextarea : Html FrontendMsg
viewMobileKeyboardTextarea =
    Html.textarea
        [ Attr.class "md:hidden"
        , Attr.class "fixed top-0 right-0 bottom-0 left-0 z-5"
        , Attr.class "opacity-0"
        , Attr.autofocus True
        , Events.onInput KeyPressed
        ]
        []


thockTrigger : String -> List Char -> Html.Html msg
thockTrigger keyboard recentKeys =
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
                , Attr.attribute "keyboard" keyboard
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
