module Evergreen.V4.Types exposing (..)

import Browser
import Browser.Navigation
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , message : String
    , recentKeys : List Char
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


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = TypedCharacter Int (List Char)
