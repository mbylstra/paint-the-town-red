module Apis.Github where

import Effects exposing (Effects, Never)
import Http
import Json.Decode as Decode exposing (Decoder, (:=), string)
import Result exposing (Result(Ok))
import Task exposing (Task)
import String



decodeUserAvatarUrl : Decoder String
decodeUserAvatarUrl =
  "avatar_url" := string

getUserAvatarUrl : String -> Task a (Maybe String)
getUserAvatarUrl username =
  let
    url = "https://api.github.com/users/" ++ username
  in
    Http.get decodeUserAvatarUrl url
      |> Task.toMaybe
