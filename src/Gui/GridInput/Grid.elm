module Gui.GridInput.Grid where

import Html exposing (..)
import Html.Attributes exposing (style, class)
-- import Html.Events exposing (onClick)

import Gui.GridInput.Cell as Cell exposing (Action)

import Matrix exposing (Matrix)
import Array


-- MODEL

type alias Model = Matrix Bool

init : Int -> Int -> Model
init width height =
  Matrix.repeat width height (Cell.init False)


allTrue : Model -> Bool
allTrue model =
  Array.length (Matrix.filter (\val -> val == False) model) == 0


type Action
  = CellAction { x : Int, y : Int} Cell.Action


update : Action -> Model -> Model
update action model =
  case action of
    CellAction pos cellAction->
      let
        cellModel = Matrix.get pos.x pos.y
      in
        Matrix.update pos.x pos.y (Cell.update cellAction) model


-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "grid"]
    ( Matrix.indexedMapListRows
      (\y row ->
        (rowView address y row)
      )
      model
    )


rowView : Signal.Address Action -> Int -> List Bool -> Html
rowView address y row =
  div [ class "row" ]
    ( List.indexedMap
      (\x cell ->
        (Cell.view (Signal.forwardTo address (CellAction {x=x, y=y})) cell)
      )
      row
    )
