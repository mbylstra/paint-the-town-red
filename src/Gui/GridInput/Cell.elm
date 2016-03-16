module Gui.GridInput.Cell
  ( init
  , update
  , view
  , Model
  , Action
  )
  where

import Html exposing (..)
import Html.Attributes exposing (classList)
import Html.Events exposing (onClick, onMouseDown, onMouseEnter, onMouseLeave)


-- MODEL

type alias Model = Bool -- Is the cell on or off?

init : Bool -> Model
init model = model


-- UPDATE

type Action = MouseDown | MouseEnter | MouseLeave

update : Action -> Model -> Model
update action model =
  case action of
    MouseDown ->
      not model
    MouseEnter ->
      not model
    MouseLeave ->
      model


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ onMouseDown address MouseDown
    , onMouseEnter address MouseEnter
    , onMouseLeave address MouseLeave
    , classList [("cell", True), ("active", model)]
    ]
    []
