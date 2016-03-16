module Css where

import Html exposing (text, node)

{- yes, this is a pretty gross way of doing css, but it means you don't
  have to bother with gulp/grunt/webpack :)
-}
styleNode cssString =
  node "style" [] [ text cssString ]

css =
  """
    @import url(https://fonts.googleapis.com/css?family=Montserrat:700,400);
    @import url(https://fonts.googleapis.com/css?family=Source+Code+Pro:200,700);
    body {
      padding: 40px;
      font-family: 'Montserrat', Arial, serif; font-weight: 400;
      height: auto;
    }

    a {
      color: rgb(234,21,122);
    }
    h2 {
      font-family: 'Montserrat', Arial, serif; font-weight: 700;
    }
    h3 {
      font-family: 'Montserrat', Arial, serif; font-weight: 400;
    }
    .app {
      display: flex;
      justify-content: center;
    }
    .grid {
      display: flex;
      width: 500px;
      height: 500px;
      background-image: url("town.jpg");
      background-repeat: no-repeat;
      background-position: -50px -50px;
      border: 2px solid black;
    }
    .stopwatch {
      padding: 5px;
      border: 2px solid black;
      padding-left: 30px;
      border-radius: 0px;
      color: black;
      display: inline-block;
      margin-bottom: 1em;
    }
    .stopwatch .seconds {
      font-family: 'Source Code Pro';
      font-weight: 200;
      font-size: 60px;
      display: inline-block;
    }
    .stopwatch .seconds-label {
      font-size: 12px;
      line-height: 25px;
      margin-left: 15px;
      width: 50px;
      display: inline-block;
    }
    .cell {
      width: 50px;
      height: 50px;
    }
    .playing .cell.active {
      background-color: rgba(255, 0, 0, 0.4);
    }
    .finished .cell.active {
      animation: blinker 1s linear infinite;
    }
    @keyframes blinker {
      0% { background-color: rgba(255, 0, 255, 0.4); }
      20% { background-color: rgba(255, 0, 0, 0.4); }
      40% { background-color: rgba(0, 255, 0, 0.4); }
      60% { background-color: rgba(0, 0, 255, 0.4); }
      80% { background-color: rgba(0, 255, 255, 0.4); }
      100% { background-color: rgba(255, 255, 0, 0.4); }
    }
    .scores-panel {
      height: 510px;
      margin-left: 100px;
      width: 360px;
    }

    .scores-panel table {
      border-spacing: 0;
    }

    .scores-panel table img {
      width: 40px;
      padding-top: 16px;
      border-radius: 50px;
      margin-top: -12px;
    }
    .scores-panel .duration {
      font-family: 'Source Code Pro';
      font-weight: 700;
      font-size: 18px;
    }

    .scores-panel td {
      vertical-align: middle;
      padding-right: 10px;
      border-top: 1px solid black;
    }

    input[type=text] {
      vertical-align: top;
      border: 2px solid black;
      height: 30px;
      padding-left: 15px;
      font-family: 'Montserrat', Arial, serif; font-weight: 400;
    }
    input[type=submit] {
      vertical-align: top;
      height: 36px;
      border: 0px;
      color: white;
      padding: 10px 20px;
      font-family: 'Montserrat', Arial, serif; font-weight: 700;
      background-color: #E0E0E0;
    }
    form.valid input[type=submit] {
      background-color: #B15959;
    }
    form.valid input[type=submit]:hover {
      background-color: #BB0505;
    }
    .submission {
      margin-bottom: 2em;
    }
    .well-done-text {
      font-family: 'Helvetica', 'arial', 'sans-serif';
    }
    .party-time {
      display: flex;
      justify-content: space-between;
    }


    /* https://github.com/tobiasahlin/SpinKit */
    .sk-three-bounce {
      margin: 40px auto;
      width: 80px;
      text-align: center; }
      .sk-three-bounce .sk-child {
        width: 20px;
        height: 20px;
        background-color: #333;
        border-radius: 100%;
        display: inline-block;
        -webkit-animation: sk-three-bounce 1.4s ease-in-out 0s infinite both;
                animation: sk-three-bounce 1.4s ease-in-out 0s infinite both; }
      .sk-three-bounce .sk-bounce1 {
        -webkit-animation-delay: -0.32s;
                animation-delay: -0.32s; }
      .sk-three-bounce .sk-bounce2 {
        -webkit-animation-delay: -0.16s;
                animation-delay: -0.16s; }

    @-webkit-keyframes sk-three-bounce {
      0%, 80%, 100% {
        -webkit-transform: scale(0);
                transform: scale(0); }
      40% {
        -webkit-transform: scale(1);
                transform: scale(1); } }

    @keyframes sk-three-bounce {
      0%, 80%, 100% {
        -webkit-transform: scale(0);
                transform: scale(0); }
      40% {
        -webkit-transform: scale(1);
                transform: scale(1); } }


    .footer {
      position: fixed;
      width: 100%;
      height: 50px;
      bottom: 0px;
      right: 0px;
      display: flex;
      justify-content: flex-end;
    }
    .footer p {
      display: inline-block;
      padding: 8px;
      padding-right: 20px;
      font-size: 12px;
      text-align: right;
      background-color: white;
    }

  """

pttrStyleNode = styleNode css
