port module Spelling exposing (..)

import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Basics
import Random exposing (int, generate)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { number : Int 
    , word : String
    , suggestions : List String
    }

init : ( Model, Cmd Msg )
init =
    ( Model 0 "" [], Cmd.none )

-- UPDATE

type Msg
    = Change String
    | Rnd Int
    | Check
    | Suggest (List String)


port check : Int -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change newWord ->
            ( Model 0 newWord [] , Cmd.none )

        Check ->
            ( (log "model" model) , generate Rnd (int -100 100) )

        Rnd n ->
            ({model | number = (log "number" n)} , check model.number)

        Suggest newSuggestions ->
            ( {model | suggestions = newSuggestions}, Cmd.none )



-- SUBSCRIPTIONS


port suggestions : (List String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    suggestions Suggest



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput Change ] []
        , button [ onClick Check ] [ text "Check" ]
        , div [] [ text (String.join ", " model.suggestions) ]
        , div [] [ text (model.number |> toString ) ]
        ]
