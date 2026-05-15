module Evergreen.V16.Types exposing (..)

import Browser
import Browser.Navigation
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
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
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
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
