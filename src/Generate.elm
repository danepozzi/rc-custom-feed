module Generate exposing (main)

import Browser exposing (..)
import Dict exposing (Dict)
import Element exposing (Column)
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
    , issue : Maybe Int
    , keyword : String
    , elements : Int
    , order : String
    , portals : PortalDict
    , width : String
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
            ( { portal = Nothing, issue = Nothing, width = "wide", keyword = "", elements = 4, order = "recent", portals = portals, error = Nothing }, Cmd.none )

        Err error ->
            ( { portal = Nothing, issue = Nothing, width = "wide", keyword = "", elements = 2, order = "recent", portals = Dict.empty, error = Just (errorToString error) }, Cmd.none )


citableIframe : String -> Html Msg
citableIframe url =
    input [ style "width" "70%", type_ "text", value url ] []


type Msg
    = Increment
    | Decrement
    | UpdateKeyword String
    | SetOrder String
    | SetIframeWidth String
    | SetPortal String
    | SetIssueID String
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

        SetIframeWidth newWidth ->
            ( { model | width = newWidth }, Cmd.none )

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

        SetIssueID issueID ->
            ( { model
                | issue = String.toInt issueID
              }
            , Cmd.none
            )

        FetchData ->
            ( model, Cmd.none )


errorToString : Json.Decode.Error -> String
errorToString error =
    Json.Decode.errorToString error


withSpacing : List (Html msg) -> List (Html msg)
withSpacing =
    List.intersperse (text " ")


view : Model -> Html Msg
view model =
    let
        portalId =
            model.portal

        portalAsString =
            portalIdToString portalId

        issueID =
            case model.issue of
                Just issue ->
                    String.fromInt issue

                Nothing ->
                    ""

        url =
            "https://rcdata.org/?keyword=" ++ model.keyword ++ "&elements=" ++ String.fromInt model.elements ++ "&order=" ++ model.order ++ "&portal=" ++ portalAsString ++ "&issue=" ++ issueID ++ "&feed=" ++ model.width

        maxElementsWithTitle =
            if model.width == "column" then
                7

            else
                11

        heightMultiplier =
            if model.width == "column" then
                1100

            else
                2000

        iFrameDiv =
            if model.width == "column" then
                div []
                    [ iframe
                        [ src (url ++ "&mode=generate"), style "width" "100%", style "max-width" "1024px", height iframeHeight ]
                        []
                    ]

            else
                div []
                    [ iframe
                        [ src (url ++ "&mode=generate"), style "width" "100%", height iframeHeight ]
                        []
                    ]

        iframeHeight =
            if model.elements < maxElementsWithTitle then
                round (7 / (4 * toFloat model.elements) * heightMultiplier)

            else
                round (1 / toFloat model.elements * heightMultiplier)

        portalOptions =
            List.map portalOption (Dict.keys model.portals)
    in
    div [ align "center" ]
        [ div []
            [ h1 []
                [ text "Generate Feed" ]
            ]
        , div []
            (withSpacing
                [ text "Portal: "
                , select [ onInput SetPortal ]
                    portalOptions
                , text "Issue: "
                , input [ placeholder "ID", value issueID, onInput SetIssueID ] []
                , text "Feed: "
                , select [ onInput SetIframeWidth ]
                    (List.map orderOption [ "wide", "column" ])
                ]
            )
        , div []
            (withSpacing
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
            )

        --, div [ style "width" "100%" ] [ citableIframe ("<div class=\"contdiv" ++ String.fromInt model.elements ++ "\"><iframe src=" ++ q url ++ " style=\"border: none;\"></iframe></div>") ]
        , br [] []
        , iFrameDiv
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
