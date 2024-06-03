module Generate exposing (main)

import Browser exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Decode exposing (Decoder, decodeString, dict, int)
import Portals exposing (portalsList)


type alias PortalDict =
    Dict String Int


portalDecoder : Decoder PortalDict
portalDecoder =
    dict int


type alias Model =
    { portal : Maybe Int
    , keyword : String
    , elements : Int
    , order : String
    , portals : PortalDict
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        jsonString =
            portalsList

        decodedPortals =
            decodeString portalDecoder jsonString
    in
    case decodedPortals of
        Ok portals ->
            ( { portal = Nothing, keyword = "", elements = 2, order = "recent", portals = portals, error = Nothing }, Cmd.none )

        Err error ->
            ( { portal = Nothing, keyword = "", elements = 2, order = "recent", portals = Dict.empty, error = Just (errorToString error) }, Cmd.none )


citableIframe : String -> Html Msg
citableIframe url =
    input [ type_ "text", value url ] []


type Msg
    = Increment
    | Decrement
    | UpdateKeyword String
    | SetOrder String
    | SetPortal String
    | FetchData


update : Msg -> Model -> ( Model, Cmd Msg )
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

        SetPortal portalName ->
            ( let
                newPortal =
                    getPortalId model.portals portalName
              in
              { model
                | portal = newPortal
              }
            , Cmd.none
            )

        FetchData ->
            ( model, Cmd.none )


errorToString : Json.Decode.Error -> String
errorToString error =
    Json.Decode.errorToString error


view : Model -> Html Msg
view model =
    let
        portalId =
            model.portal

        portalAsString =
            portalIdToString portalId

        url =
            "https://rcfeed.sarconference2016.net/?keyword=" ++ model.keyword ++ "&elements=" ++ String.fromInt model.elements ++ "&order=" ++ model.order ++ "&portal=" ++ portalAsString

        iframeHeight =
            if model.elements < 4 then
                800

            else
                500

        portalOptions =
            List.map portalOption (Dict.keys model.portals)
    in
    div [ align "center" ]
        [ div []
            [ h1 []
                [ text "Generate Feed" ]
            ]
        , div []
            [ text "Portal: "
            , select [ onInput SetPortal ]
                portalOptions
            ]
        , div []
            [ text "Keyword: "
            , input [ placeholder "Type your keyword here", value model.keyword, onInput UpdateKeyword ] []
            , text "Number of Elements to Display: "
            , button [ onClick Decrement ] [ text "-" ]
            , text (String.fromInt model.elements)
            , button [ onClick Increment ] [ text "+" ]
            , text "Order of Elements: "
            , select [ onInput SetOrder ]
                (List.map orderOption [ "recent", "random" ])
            ]
        , div [] [ citableIframe ("<div class=\"contdiv" ++ String.fromInt model.elements ++ "\"><iframe src=" ++ q url ++ " style=\"border: none;\"></iframe></div>") ]
        , br [] []
        , div []
            [ iframe
                [ src url, style "width" "100%", height iframeHeight ]
                []
            ]
        , div []
            [ text "Copy the following HTML code in the HTML tool in your block page:" ]
        ]


q : String -> String
q str =
    "\"" ++ str ++ "\""


portalOption : String -> Html msg
portalOption portalName =
    option [ value portalName ] [ text portalName ]


getPortalId : PortalDict -> String -> Maybe Int
getPortalId portals portalName =
    Dict.get portalName portals


orderOption : String -> Html msg
orderOption order =
    option [ value order ] [ text order ]


portalIdToString : Maybe Int -> String
portalIdToString id =
    case id of
        Just int ->
            String.fromInt int

        Nothing ->
            ""


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
