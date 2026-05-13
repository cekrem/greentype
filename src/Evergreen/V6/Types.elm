module Evergreen.V6.Types exposing (..)

import Browser
import Browser.Navigation
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
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
    | KeyPressed String


type ToBackend
    = ClientTyped Char
    | RequestedData


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = DataUpdated Int (List Char)
