module Main exposing (main)

import AppUrl exposing (AppUrl)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Carousel exposing (Carousel)
import Decode exposing (..)
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Http
import Json.Decode exposing (Error(..))
import Random
import Random.List exposing (shuffle)
import Url exposing (Url)


parametersFromAppUrl : AppUrl -> Parameters
parametersFromAppUrl url =
    Parameters
        (Dict.get
            "keyword"
            url.queryParameters
            |> Maybe.andThen List.head
        )
        (Dict.get "elements" url.queryParameters
            |> Maybe.andThen List.head
            |> Maybe.andThen String.toInt
        )
        (Dict.get
            "order"
            url.queryParameters
            |> Maybe.andThen List.head
        )


shuffleWithSeed : Int -> List a -> List a
shuffleWithSeed seed lst =
    Random.initialSeed seed
        |> Random.step (shuffle lst)
        |> Tuple.first


type Msg
    = NoOp
    | ChangeUrl Url
    | RequestUrl Browser.UrlRequest
    | NextExposition
    | DataReceived (Result Http.Error (List Exposition))
    | UpdateParameters Parameters


type alias Model =
    { navKey : Nav.Key
    , research : List Exposition
    , expositions : Carousel Exposition
    , parameters : Parameters
    , seed : Int
    , view : View
    }


type View
    = Error
    | Carousel


type alias Parameters =
    { keyword : Maybe String
    , elements : Maybe Int
    , order : Maybe String
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        model =
            { navKey = navKey
            , research = []
            , expositions = Carousel.create [] 1
            , parameters = parametersFromAppUrl (AppUrl.fromUrl url)
            , view = Carousel
            , seed = 42
            }

        _ =
            Debug.log "model" model
    in
    ( model, sendQuery (Maybe.withDefault "Nothing" model.parameters.keyword) )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ChangeUrl _ ->
            ( model, Cmd.none )

        RequestUrl _ ->
            ( model, Cmd.none )

        DataReceived (Ok expositions) ->
            let
                _ =
                    Debug.log "parameters" model.parameters

                exp =
                    case model.parameters.order of
                        Just "recent" ->
                            expositions

                        Just "random" ->
                            shuffleWithSeed 42 expositions

                        Nothing ->
                            expositions

                        Just _ ->
                            expositions
            in
            ( { model
                | expositions = Carousel.create exp (Maybe.withDefault 1 model.parameters.elements)
              }
            , Cmd.none
            )

        DataReceived (Err error) ->
            let
                _ =
                    Debug.log "error" error
            in
            ( { model | view = Error }, Cmd.none )

        NextExposition ->
            ( { model | expositions = Carousel.next model.expositions }, Cmd.none )

        UpdateParameters p ->
            let
                _ =
                    Debug.log "parameters" p
            in
            ( { model | parameters = p }, Cmd.none )


sendQuery : String -> Cmd Msg
sendQuery keyw =
    let
        -- this should later be:
        -- request = "https://www.researchcatalogue.net/portal/search-result?fulltext=&title=&autocomplete=&keyword="
        -- ++ keyw
        -- "&portal=&statusprogress=0&statuspublished=0&includelimited=0&includelimited=1&includeprivate=0&includeprivate=1&type_research=research&resulttype=research&modifiedafter=&modifiedbefore=&format=json&limit=50&page=0"
        request =
            "http://localhost:5019/" ++ keyw

        _ =
            Debug.log "send query" request
    in
    Http.get
        { url = request
        , expect = Http.expectJson DataReceived Decode.expositionsDecoder
        }



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case model.view of
                Carousel ->
                    [ layout [ width fill ]
                        (Carousel.view
                            { carousel = model.expositions
                            , onNext = NextExposition
                            , viewSlide = viewResearch
                            , num = Maybe.withDefault 1 model.parameters.elements - 1
                            }
                        )
                    ]

                Error ->
                    [ layout [ width fill ] (Element.text "bad query. you must provide keyword, number of elements and order. example: http://localhost:8080/?keyword=kcpedia&elements=2&order=recent") ]
    in
    { title = "custom-feed"
    , body = content
    }


viewResearch : List (Maybe Exposition) -> List (Element Msg)
viewResearch exp =
    [ Element.column [ width fill ]
        (List.concat
            [ List.map
                viewExposition
                exp
            , [ Input.button
                    [ width fill
                    , Background.color (rgb255 0 255 144)
                    , Border.color (rgb255 0 0 0)
                    , Border.width 2
                    , Border.rounded 3
                    , Element.focused
                        [ Background.color (rgb255 0 255 255) ]
                    , centerX
                    ]
                    { onPress = Just NextExposition
                    , label = Element.text " > "
                    }
              ]
            ]
        )
    ]


viewExposition : Maybe Exposition -> Element Msg
viewExposition exp =
    case exp of
        Just exposition ->
            Element.row
                [ width fill
                , Border.color (rgb255 0 0 0)
                , Border.width 2
                , Border.rounded 3
                ]
                [ paragraph
                    [ Background.color (rgb255 0 250 160)
                    , height fill
                    ]
                    [ Element.text (Maybe.withDefault "" exposition.thumb) ]
                , Element.column
                    [ width fill, spacing 5, padding 5 ]
                    [ paragraph
                        [ Background.color (rgb255 0 255 255)
                        , height fill
                        ]
                        [ Element.text exposition.title ]
                    , paragraph
                        [ Background.color (rgb255 0 250 160)
                        , height fill
                        ]
                        [ Element.text exposition.author.name ]
                    , paragraph
                        [ Element.height
                            (fill |> maximum 100 |> minimum 100)
                        , scrollbarY
                        , Background.color (rgb255 160 250 100)
                        ]
                        [ Element.text exposition.abstract ]
                    ]
                ]

        Nothing ->
            Element.text "Loading..."


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = ChangeUrl
        , onUrlRequest = RequestUrl
        }
