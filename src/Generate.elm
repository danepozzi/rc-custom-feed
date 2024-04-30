module Generate exposing (main)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { elements : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { elements = 2 }, Cmd.none )


type Msg
    = Increment
    | Decrement


update msg model =
    case msg of
        Increment ->
            ( { model | elements = model.elements + 1 }, Cmd.none )

        Decrement ->
            ( { model | elements = model.elements - 1 }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        url =
            "https://rcfeed.sarconference2016.net/?keyword=music&elements=" ++ String.fromInt model.elements ++ "&order=recent"
    in
    div [ align "center" ]
        [ div []
            [ h1 []
                [ text "Generate Feed" ]
            ]
        , div
            []
            [ text "Number of Elements to Display: "
            , button [ onClick Decrement ] [ text "-" ]
            , text (String.fromInt model.elements)
            , button [ onClick Increment ] [ text "+" ]
            ]
        , div
            []
            [ iframe
                [ width 1200, height 800, src url ]
                []
            ]
        , div []
            [ text "Copy the following HTML code in the HTML tool in your block page:" ]
        , div []
            [ text ("<p><iframe " ++ url ++ " width=\"100%\" height=" ++ String.fromInt 800 ++ "\" style=\"border: none;\"></iframe></p>") ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
