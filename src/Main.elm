import Html             exposing (..)
import Html.Events      exposing (..)
import Html.Attributes  exposing (..)

import Http

import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

main : Program Never Model Msg

main = 
    Html.program
        { init          = init
        , update        = update
        , subscriptions = \_ -> Sub.none
        , view          = view
        }
{-

    Model
    *Model type
    *Initialize model with empty values

-}

type alias Model =
    { username : String
    , quote : String 
    , token : String
    , quote : String
    , errorMsg : String
    }

init :  ( Model, Cmd Msg )

init = 
    ( Model "" "" "" "" "" , fetchRandomQuoteCmd )


{-

    Updates
    * API routes
    * GET
    * message 
    * update case

-}

-- API requests url


api : String

api =
    "http://localhost:3000/"


registerUrl : String

registerUrl = 
    api ++ "users"

userEncoder : Model ->  Encode.Value
userEncoder =
    Encode.object
        [ ("username", Encode.string model.username)
        , ("password", Encode.string model.password)
        ]

authUser : Model -> String -> Http.Request String

authUser model apiUrl =
    let 
        body =
            model
                |> userEncoder
                |> Http.jsonBody
    in
        Http.post upiUrl body tokenDecoder

authUserCmd : Model -> String -> Cmd Msg
authUserCmd model apiUrl =
    Http.send    GetTokenCompleted (authUser model apiUrl)

getTokenCompleted : Model -> Result Http.Error String -> (Model, Cmd Msg)
getTokenCompleted model result =
    case result of
        Ok newToken ->
            ( { model | token = newToken, password = "", errorMsg = "" } |> Debug.log "got new token", Cmd.none )

        Err error -> 
            ( { model | errorMsg = (toString error) }, Cmd.none )

tokenDecoder : Decoder String
tokenDecoder =
    Decode.field "access token" Decode.string

randomQuoteUrl : String

randomQuoteUrl = 
    api ++ "api/random-quote"

fetchRandomQuote :  Http.Request String

fetchRandomQuote =
    Http.getString randomQuoteUrl

fetchRandomQuoteCmd : Cmd Msg

fetchRandomQuoteCmd = 
    Http.send FetchRandomQuoteCompleted fetchRandomQuote

fetchRandomQuoteCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg)

fetchRandomQuoteCompleted model result =
    case  result of
        Ok newQuote ->
            ( { model | quote = newQuote}, Cmd.none )

        Err _ -> 
            ( model, Cmd.none )


type Msg
    = GetQuote
    | FetchRandomQuoteCompleted (Result Http.Error String)  

update : Msg -> Model -> (Model, Cmd Msg)


update msg model = 
    case msg of 
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchRandomQuoteCompleted result ->
            fetchRandomQuoteCompleted model result

        SetUserName username ->
            ({model | username = username}, Cmd.none)

        SetPassword password ->
            ({model | password = password}, Cmd.none)

        ClickRegisterUser ->
            (model, authUserCmd model registerUrl)

        GetTokenCompleted result ->
            getTokenCompleted model result
{-

    View

-}


view :  Model -> Html Msg

view model = 
    div [ class "container" ] [
        h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ] [
            button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote" ]
        ]
        --Blockquote with quote
        , blockquote [] [
            p [] [text model.quote]
        ]
    ]