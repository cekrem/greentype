module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
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
    | KeyPressed String


type ToBackend
    = ClientTyped Char
    | RequestedData


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = DataUpdated Int (List Char)
