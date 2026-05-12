module Evergreen.V2.Types exposing (..)

import Browser
import Browser.Navigation
import Url


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , message : String
    , lastKey : Maybe String
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
    = ClientTyped String


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = TypedCharacter Int String
