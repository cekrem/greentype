module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , keyboard : String
    , data :
        Maybe
            { message : String
            , recentKeys : List Char
            }
    }


type alias BackendModel =
    { typedCharacters : Int
    , recentKeys : List Char
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | KeyboardChanged String
    | KeyPressed String
    | BlurredSelect


type ToBackend
    = ClientTyped Char
    | RequestedData


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = DataUpdated Int (List Char)
