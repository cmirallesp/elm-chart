port module Quote exposing (..)

import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Basics
import Random exposing (int, generate)
import Time exposing (..)
import Strftime exposing (format)
import Date exposing (fromTime)

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
    , tstamp : String
    , suggestions : List String
    }

init : ( Model, Cmd Msg )
init =
    ( Model 0 "" [], Cmd.none )

-- UPDATE

type Msg
    = Rnd Int
    | Check
    | Suggest (List String)
    | Tick Time


port check : (Int, String) -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Check ->
            ( (log "model" model) , generate Rnd (int -100 100) )

        Rnd n ->
            ({model | number = (log "number" n)} , check (model.number, model.tstamp))

        Suggest newSuggestions ->
            ( {model | suggestions = newSuggestions}, Cmd.none )

        Tick time ->
            -- ( {model | tstamp = time}, check (model.number, model.tstamp))
            let
                t = (format "%a %d %Y, %-H:%-M:%-S" (Date.fromTime time))
                -- t = (format "%X" (Date.fromTime time))
            in
                ( {model | tstamp = t}, generate Rnd (int -100 100) )


-- SUBSCRIPTIONS


port suggestions : (List String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ suggestions Suggest
        , every (second * 2) Tick
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Check ] [ text "Check" ]
        , div [] [ text (String.join ", " model.suggestions) ]
        , div [] [ text (model.number |> toString ) ]
        ]
