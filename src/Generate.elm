module Generate exposing (main)

import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


type alias Model =
    { keyword : String
    , elements : Int
    , order : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { keyword = "", elements = 2, order = "recent" }, Cmd.none )


type Msg
    = Increment
    | Decrement
    | UpdateKeyword String
    | SetOrder String


update msg model =
    case msg of
        Increment ->
            ( { model | elements = model.elements + 1 }, Cmd.none )

        Decrement ->
            ( { model | elements = model.elements - 1 }, Cmd.none )

        UpdateKeyword newKeyword ->
            ( { model | keyword = newKeyword }, Cmd.none )

        SetOrder newOrder ->
            ( { model | order = newOrder }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        url =
            "https://rcfeed.sarconference2016.net/?keyword=" ++ model.keyword ++ "&elements=" ++ String.fromInt model.elements ++ "&order=" ++ model.order ++ "\""

        iframeHeight =
            if model.elements < 4 then
                800

            else
                500

        --round (1000 / toFloat model.elements)
    in
    div [ align "center" ]
        [ div []
            [ h1 []
                [ text "Generate Feed" ]
            ]
        , div []
            [ text "Keyword: "
            , input [ placeholder "Type your keyword here", value model.keyword, onInput UpdateKeyword ] []
            ]
        , div
            []
            [ text "Number of Elements to Display: "
            , button [ onClick Decrement ] [ text "-" ]
            , text (String.fromInt model.elements)
            , button [ onClick Increment ] [ text "+" ]
            ]
        , div []
            [ text "Order of Elements: "
            , select [ width 300, onInput SetOrder ]
                [ text "recent", text "random" ]
            ]
        , div
            []
            [ iframe
                [ width 1200, height iframeHeight, src url ]
                []
            ]
        , div []
            [ text "Copy the following HTML code in the HTML tool in your block page:" ]
        , div []
            [ text ("<p><iframe " ++ url ++ " width=\"100%\" height=" ++ String.fromInt iframeHeight ++ "\" style=\"border: none;\"></iframe></p>") ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
