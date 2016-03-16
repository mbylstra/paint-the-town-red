import StartApp

import Task exposing (Task)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Json.Decode as JD exposing ((:=), maybe)
import Json.Encode as JE
import Dict exposing (Dict)
import Time exposing (Time)
import String

import Html exposing (Html, div, button, text, node, h2, p, input)
import Html.Events as Events exposing (onClick, targetValue, on, onSubmit, onWithOptions)
import Html.Attributes exposing (class, classList, placeholder, value, type', src, href)

import Number.Format

import ElmFire
import ElmFire.Dict
import ElmFire.Op

import Apis.Github exposing (getUserAvatarUrl)
import Gui.GridInput.Grid as Grid
import Css exposing (pttrStyleNode)


firebaseUrl = "https://vivid-torch-4218.firebaseio.com/"



-- MODEL

type GameProgress = NotStarted | Playing | Finished | BestTimeSubmitted

type alias Model =
  { grid : Grid.Model
  , bestTimes : Maybe BestTimes
  , gameProgress : GameProgress
  , ticksElapsed : Int
  , currGithubUsername : String
  , currAvatarUrl : Maybe String
  }

type alias BestTimes = Dict Id BestTime
type alias Id = String
type alias BestTime =
  { username : String
  , duration : Int
  , avatarUrl : Maybe String
  }

init : Int -> Int -> Model
init width height =
  { grid = Grid.init width height
  , bestTimes = Nothing
  , gameProgress = NotStarted
  , ticksElapsed = 0
  , currGithubUsername = ""
  , currAvatarUrl = Nothing
  }


-- UPDATE

type Action
  = GridAction Grid.Action
  | GithubUsernameUpdated String
  | SubmitBestTime String Int
  | GotAvatar String (Maybe String)
  | StartAgain
  | FromServer BestTimes
  | FromEffect
  | ClockTick


update : Action -> Model -> (Model, Effects Action)
update action model =
  -- case (Debug.log "action" action) of
  case action of
    GridAction gridAction ->
      let
        newGrid = Grid.update gridAction model.grid
        newGameProgress =
          case model.gameProgress of
            NotStarted ->
              Playing
            Playing ->
              if Grid.allTrue newGrid then Finished else Playing
            _ -> model.gameProgress
      in
      ( { model |
          grid = newGrid,
          gameProgress = newGameProgress
        }
      , Effects.none
      )
    ClockTick ->
      case model.gameProgress of
        Playing ->
          ({ model | ticksElapsed = model.ticksElapsed + 1 }, Effects.none)
        _ ->
          (model, Effects.none)
    GithubUsernameUpdated s ->
      ({ model | currGithubUsername = s}, Effects.none)
    SubmitBestTime username duration ->
      let
        getAvatarTask = getUserAvatarUrl username
      in
        ( { model | gameProgress = BestTimeSubmitted, currAvatarUrl = Nothing }
        , getAvatarTask |> Task.map (GotAvatar username) |> Effects.task
        )
    GotAvatar username maybeUrl ->
      ( model
      , effectItems <|
          ElmFire.Op.insert username
            { username = username
            , duration = model.ticksElapsed
            , avatarUrl = maybeUrl
            }
      )
    StartAgain ->
      (init 10 10, initialEffect)
    FromEffect ->
      (model, Effects.none)
    FromServer bestTimes ->
      Debug.log "FromServer" ( { model | bestTimes = Just bestTimes }, Effects.none )


-- VIEW


view address model =
  div []
    [ pttrStyleNode
    , div []
      [ div [ class "app"]
        [ mainView address model
        , scoresPanelView address model
        ]
      ]
    , div [ class "footer"]
      [ p []
        [ text "Made with the "
        , a [ href "http://elm-lang.org/" ] [ text "Elm programming language" ]
        , text " by "
        , a [ href "https://github.com/mbylstra" ] [ text "@mbylstra  |  " ]
        , text " Fantastic town illustration by "
        , a [ href "https://www.flickr.com/photos/36106576@N05/3960016602" ] [ text "Don Moyer" ]
        ]
      ]
    ]

mainView address model =
  div []
    [ h2 [] [ text "PAINT THE TOWN RED"]
    , gameView address model
    , gameProgressView address model.gameProgress
    ]

gameProgressView address gameProgress =
  let
    message =
      case gameProgress of
        NotStarted -> p [] [ text  "Move the cursor into the town area to start." ]
        Playing -> p [] [ text "Don't stop until the town's fully red." ]
        _ ->
          p [ class "party-time"]
            [ div [] [ text "Party time!" ]
            , a [ href "#", onClick address StartAgain ] [ text "Play again?" ]
            ]
  in
    p [] [ message ]

gameView address model =
  let
    progressClass =
      case model.gameProgress of
        NotStarted -> "not-started"
        Playing -> "playing"
        Finished -> "finished"
        BestTimeSubmitted -> "finished"
  in
    div
      [ classList
        [ ("stage", True)
        , (progressClass, True)
        ]
      ]
      [ Grid.view (Signal.forwardTo address GridAction) model.grid ]

scoresPanelView address model =
  div [ class "scores-panel" ]
    [ h2 [ class "scores-heading"] [ text "Your Time" ]
    , clockView model
    , enterBestTimeView address model
    , h3 [] [ text "Best Times" ]
    , bestTimesListView model.bestTimes
    ]

dlHelper : String -> List (String, String) -> Html
dlHelper cssClass items =
  let
    dtHelper : (String, String) -> List Html
    dtHelper (key, value) =
      [ dt [] [ text key ]
      , dd [] [ text value ]
      ]

    ddItems : List Html
    ddItems =
      items
        |> List.map dtHelper
        |> List.concat
  in
    dl [ class cssClass ] (ddItems)


tableRow : List Html -> Html
tableRow cellInnards =
  let
    cellsHtml = List.map (\cellInnard -> td [] [ cellInnard ]) cellInnards
  in
    tr [] cellsHtml

tableMaker : List (List Html) -> Html
tableMaker rows =
  let
    rowsHtml = List.map (\row -> tr [] [tableRow row]) rows
  in
    table [] rowsHtml

bestTimesListView bestTimes =
  case bestTimes of
    Just bestTimes' ->
      let
        sortedList =
          bestTimes'
          |> Dict.values
          |> List.sortBy .duration
          |> List.take 100
          |> List.map
            (\bestTime ->
              [ span [ class "duration" ] [ text <| formatDuration bestTime.duration ]
              , case bestTime.avatarUrl of
                  Nothing -> text ""
                  Just url -> img [ src url ] []
              , text bestTime.username
              ]
            )
      in
        tableMaker sortedList

    Nothing ->
      spinner

formatDuration durationTenths =
  let
    durationSeconds = (toFloat durationTenths) / 10.0
    formatted = Number.Format.pretty 1 ',' durationSeconds
  in
    leftPadFloatString '0' 2 formatted

leftPadIntString padChar width nString =
  let
    padLength = width - (String.length nString)
  in
    (String.repeat padLength (String.fromChar padChar)) ++  nString

leftPadFloatString padChar width nFloat =
  let
    parts = String.split "." nFloat
  in
    case parts of
      whole::fraction::[] ->
        leftPadIntString padChar width whole ++ "." ++ fraction
      _ ->
        Debug.crash "This crash shouldn't be possible :)"

clockView model =
  let
    number = model.ticksElapsed |> formatDuration
  in
    div [ class "stopwatch" ]
      [ div [ class "seconds" ] [ text number ]
      , div [ class "seconds-label" ] [ text "secs" ]
      ]


isUsernameValid username =
  if String.length username > 2 then True else False

enterBestTimeView address model =
  case model.gameProgress of
    Finished ->
      div [ class "submission" ]
        [ p [ class "well-done-text"]
            [ text "Well Done! Enter your github username to enter your time in the Best Times leaderboard."]
        , submitBestTimeForm address model
        ]
    _ ->
      span [] []


submitBestTimeForm address model =
  form
    [ onWithOptions
      "submit"
      { preventDefault = True, stopPropagation = False }
      ( JD.succeed Nothing )
      (\_ ->
        Signal.message
          address
          (SubmitBestTime model.currGithubUsername model.ticksElapsed)
      )
    , classList [("valid", isUsernameValid model.currGithubUsername)]
    ]
    [ currGithubUsernameInput address
    , input [ type' "submit", value "Show the world!" ] []
    ]

currGithubUsernameInput address =
  input
    [ type' "text"
    , placeholder "your github username"
    , on
        "input"
        targetValue (\v -> Signal.message address (GithubUsernameUpdated v))
    ]
    []

spinner =
  div [ class "sk-three-bounce" ]
      [ div [ class "sk-child sk-bounce1" ] []
      , div [ class "sk-child sk-bounce2" ] []
      , div [ class "sk-child sk-bounce3" ] []
      ]

--------------------------------------------------------------------------------

-- Mirror Firebase's content as the model's items

-- initialTask : Task Error (Task Error ())
-- inputItems : Signal Items
(initialTask, inputItems) =
  ElmFire.Dict.mirror syncConfig

initialEffect : Effects Action
initialEffect = initialTask |> kickOff

--------------------------------------------------------------------------------

syncConfig : ElmFire.Dict.Config BestTime
syncConfig =
  { location = ElmFire.fromUrl firebaseUrl
  , orderOptions = ElmFire.noOrder
  , encoder =
      \bestTime -> JE.object
        [ ( "username", JE.string bestTime.username)
        , ( "duration", JE.int bestTime.duration)
        , ( "avatarUrl"
          , case bestTime.avatarUrl of
              Nothing -> JE.null
              Just url -> JE.string url
          )
        ]
  , decoder =
      ( JD.object3 BestTime
          ("username" := JD.string)
          ("duration" := JD.int)
          (maybe ("avatarUrl" := JD.string))
      )
  }

--------------------------------------------------------------------------------

effectItems : ElmFire.Op.Operation BestTime -> Effects Action
effectItems operation =
  ElmFire.Op.operate
    syncConfig
    operation
  |> kickOff

--------------------------------------------------------------------------------

-- Map any task to an effect, discarding any direct result or error value
kickOff : Task x a -> Effects Action
kickOff =
  Task.toMaybe >> Task.map (always (FromEffect)) >> Effects.task


--------------------------------------------------------------------------------

config : StartApp.Config Model Action
config =
  { init = (init 10 10, initialEffect)
  , update = update
  , view = view
  , inputs = [Signal.map FromServer inputItems, tenthSecondSignal]
  }

app : StartApp.App Model
app = StartApp.start config

port runEffects : Signal (Task Never ())
port runEffects = app.tasks

tenthSecondSignal : Signal Action
tenthSecondSignal = Signal.map (\_ -> ClockTick) (Time.every (Time.millisecond * 100))

main : Signal Html
main = app.html
