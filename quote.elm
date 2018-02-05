port module Quote exposing (..)

import Http exposing (get,post,Error,Body)
import Json.Decode exposing (field, int, string, list, Decoder)
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

type alias Quote =
    {   quote : Int
    ,   tstamp : String
    }

quoteDecoder: Decoder Quote
quoteDecoder= 
  Json.Decode.map2 Quote 
    (field "quote" Json.Decode.int)
    (field "tstamp" Json.Decode.string)

sendGet : (Result Error a -> msg) -> String -> Decoder a -> Cmd msg
sendGet msg url decoder =
  Http.get url decoder |> Http.send msg

sendPost : (Result Error a -> msg) -> String -> Decoder a -> Body -> Cmd msg
sendPost msg url decoder body2 =
    Http.post url body2 decoder |> Http.send msg


-- MODEL


type alias Model =
    { quote : Int
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
    | Tick2 Time
    | GetQuote (Result Error Quote)

port check : (Int, String) -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Check ->
            ( (log "model" model) , generate Rnd (Random.int -100 100) )

        Rnd n ->
            ( {model | quote = (log "quote" n)} , 
               check (model.quote, model.tstamp)
            )

        Suggest newSuggestions ->
            ( {model | suggestions = newSuggestions}, Cmd.none )

        Tick time ->
            let
                t = (format "%a %d %Y, %-H:%-M:%-S" (Date.fromTime time))
            in
                ( {model | tstamp = t}, generate Rnd (Random.int -100 100) )
        Tick2 time ->
            (model, sendGet GetQuote "http://localhost:8887/quote" quoteDecoder)

        GetQuote (Ok res) ->
            ({model | tstamp = res.tstamp, quote=res.quote}, 
                check (model.quote, model.tstamp))

        GetQuote (Err res) ->
            -- (model, Cmd.none)
            (model, Cmd.none)

-- SUBSCRIPTIONS


port suggestions : (List String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ suggestions Suggest
        -- , every (second * 2) Tick
        , every (second * 2) Tick2
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Check ] [ text "Check" ]
        , div [] [ text (String.join ", " model.suggestions) ]
        , div [] [ text (model.quote |> toString ) ]
        ]
