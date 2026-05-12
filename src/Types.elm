module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , message : String
    , lastKey : Maybe String
    }


type alias BackendModel =
    { typedCharacters : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | KeyPressed String


type ToBackend
    = ClientTyped String


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = TypedCharacter Int String

