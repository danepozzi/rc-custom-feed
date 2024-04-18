module Main exposing (main, release, shuffleWithSeed)

import AppUrl exposing (AppUrl)
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Carousel exposing (Carousel)
import Decode exposing (..)
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Element.Keyed
import Element.Region exposing (description)
import Html exposing (Html)
import Html.Attributes
import Http
import Json.Decode exposing (Error(..))
import Random
import Random.List exposing (shuffle)
import String.Extra
import Url exposing (Url)


type Release
    = Live
    | Development


baseUrl r =
    case r of
        Live ->
            "https://rcfeed.sarconference2016.net/"

        Development ->
            "http://localhost:8080/"


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
    | PreviousExposition
    | DataReceived (Result Http.Error (List Exposition))
    | UpdateParameters Parameters
    | WindowWasResized Int Int


type alias Model =
    { navKey : Nav.Key
    , research : List Exposition
    , expositions : Carousel Exposition
    , parameters : Parameters
    , seed : Int
    , view : View
    , windowSize : { w : Int, h : Int }
    , release : Release
    }


type View
    = Error
    | Carousel


type alias Parameters =
    { keyword : Maybe String
    , elements : Maybe Int
    , order : Maybe String
    }


type alias Config =
    { seed : Int
    , width : Int
    , height : Int
    , release : Release
    }


defaultConfig =
    { seed = 42
    , width = 1280
    , height = 600
    , release = Live
    }


release : String -> Release
release str =
    case String.toLower str of
        "live" ->
            Live

        "devel" ->
            Development

        "development" ->
            Development

        _ ->
            Development


configDecoder : Json.Decode.Decoder Config
configDecoder =
    Json.Decode.map4
        Config
        (Json.Decode.field "seed" Json.Decode.int)
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)
        (Json.Decode.field "release" Json.Decode.string |> Json.Decode.map release)



-- init ( seed, width, height, release ) url navKey =


init : Json.Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init config url navKey =
    let
        cfg =
            case Json.Decode.decodeValue configDecoder config of
                Result.Ok c ->
                    let
                        _ =
                            Debug.log "release" c.release
                    in
                    c

                Result.Err e ->
                    let
                        _ =
                            Debug.log "invalid config" e
                    in
                    defaultConfig

        model =
            { navKey = navKey
            , research = []
            , expositions = Carousel.create [] 1
            , parameters = parametersFromAppUrl (AppUrl.fromUrl url)
            , view = Carousel
            , seed = cfg.seed
            , windowSize = { w = cfg.width, h = cfg.height }
            , release = cfg.release
            }

        _ =
            Debug.log "model" model
    in
    ( model, sendQuery cfg.release (Maybe.withDefault "Nothing" model.parameters.keyword) )



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
                            shuffleWithSeed model.seed expositions

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

        PreviousExposition ->
            ( { model | expositions = Carousel.previous model.expositions }, Cmd.none )

        UpdateParameters p ->
            let
                _ =
                    Debug.log "parameters" p
            in
            ( { model | parameters = p }, Cmd.none )

        WindowWasResized w h ->
            ( { model | windowSize = { w = w, h = h } }, Cmd.none )


sendQuery : Release -> String -> Cmd Msg
sendQuery releaseType keyw =
    let
        -- this should later be:
        -- request = "https://www.researchcatalogue.net/portal/search-result?fulltext=&title=&autocomplete=&keyword="
        -- ++ keyw
        -- "&portal=&statusprogress=0&statuspublished=0&includelimited=0&includelimited=1&includeprivate=0&includeprivate=1&type_research=research&resulttype=research&modifiedafter=&modifiedbefore=&format=json&limit=50&page=0"
        url =
            case releaseType of
                Live ->
                    "rcproxy/proxy?keyword=" ++ keyw

                Development ->
                    "http://localhost:2019/" ++ keyw

        _ =
            Debug.log "send query :" url
    in
    Http.get
        { url = url
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
                        (if model.windowSize.w > 800 then
                            Carousel.view
                                { carousel = model.expositions
                                , onNext = NextExposition
                                , viewSlide = viewResearch model.windowSize.w (Maybe.withDefault 3 model.parameters.elements)
                                , num = Maybe.withDefault 1 model.parameters.elements - 1
                                }

                         else
                            Carousel.view
                                { carousel = model.expositions
                                , onNext = NextExposition
                                , viewSlide = viewResearch model.windowSize.w 1
                                , num = 0
                                }
                        )
                    ]

                Error ->
                    let
                        url =
                            baseUrl model.release
                    in
                    [ layout [ width fill ] (Element.text <| "bad query. you must provide keyword, number of elements and order. example: " ++ url ++ "?keyword=kcpedia&elements=2&order=recent") ]
    in
    { title = "custom-feed"
    , body = content
    }


defaultPadding =
    { top = 0, bottom = 0, left = 0, right = 0 }


viewResearch : Int -> Int -> List (Maybe Exposition) -> List (Element Msg)
viewResearch w columns exp =
    let
        buttonWidth =
            30
    in
    [ Element.Keyed.row
        [ width fill, paddingEach { defaultPadding | left = 0 }, spacing 25 ]
        [ ( "prev"
          , Input.button
                [ width <| px buttonWidth
                , height fill

                --, Background.color (r)
                -- , Border.color (rgb255 0 0 0)
                -- , Border.width 2
                -- , Border.rounded 3
                , Element.focused
                    [ Border.shadow { color = rgb255 1 1 1, offset = ( 0, 0 ), blur = 0, size = 0 } ]
                , centerX

                --, moveLeft buttonWidth
                ]
                { onPress = Just PreviousExposition
                , label = Element.image [ width (px 25), height (px 25), rotate 22 ] { src = "assets/shevron.svg", description = "next slide" }
                }
          )
        , ( "content"
          , Element.row [ width fill ]
                (List.map
                    (columns |> (w |> viewExposition))
                    exp
                )
          )
        , ( "next"
          , Input.button
                [ width <| px buttonWidth
                , height fill

                --, Background.color (r)
                -- , Border.color (rgb255 0 0 0)
                -- , Border.width 2
                -- , Border.rounded 3
                , Element.focused
                    [ Border.shadow { color = rgb255 1 1 1, offset = ( 0, 0 ), blur = 0, size = 0 } ]
                , centerX

                --, moveLeft buttonWidth
                ]
                { onPress = Just NextExposition
                , label = Element.image [ width (px 25), height (px 25) ] { src = "assets/shevron.svg", description = "next slide" }
                }
          )
        ]
    ]


defaultPageFromUrl : String -> String
defaultPageFromUrl str =
    let
        expositionUrl =
            Url.fromString str

        expositionPath =
            case expositionUrl of
                Just url ->
                    url.path
                        |> String.dropLeft 5

                _ ->
                    ""
    in
    expositionPath


viewTitleAuthor : Int -> Int -> Maybe Exposition -> Element Msg
viewTitleAuthor w columns exp =
    case exp of
        Just exposition ->
            column
                [ --Border.color (rgb255 0 0 0)
                  --, Border.width 2
                  --, Border.rounded 3
                  Element.centerX
                , spacing 10
                , paddingXY 5 25
                ]
                [ paragraph
                    [ height fill
                    , Font.center
                    , Font.size (20 - columns)
                    , Font.bold
                    ]
                    [ Element.newTabLink
                        []
                        { url = exposition.url
                        , label = Element.text exposition.title
                        }
                    ]
                , paragraph
                    [ --Background.color (rgb255 0 250 160)
                      Element.centerX
                    , Font.center
                    , Font.size (20 - columns)
                    , Element.paddingEach { defaultPadding | bottom = 24 }
                    ]
                    [ Element.newTabLink
                        []
                        { url = authorLink exposition.author.id
                        , label = Element.text exposition.author.name
                        }
                    ]
                ]

        Nothing ->
            Element.text "Waiting for exposition..."


viewTitleAuthorAbstract : Int -> Int -> Maybe Exposition -> Element Msg
viewTitleAuthorAbstract w columns exp =
    case exp of
        Just exposition ->
            let
                shortAbstract =
                    String.Extra.softEllipsis 300 exposition.abstract
            in
            column [ Element.centerX, spacing 10, padding (round (toFloat w / 10 / toFloat columns)) ]
                [ paragraph
                    [ height fill
                    , Font.center
                    , Font.size (22 - columns)
                    , Font.bold
                    ]
                    [ Element.newTabLink
                        []
                        { url = exposition.url
                        , label = Element.text exposition.title
                        }
                    ]
                , paragraph
                    [ --Background.color (rgb255 0 250 160)
                      Element.centerX
                    , Font.center
                    , Font.size (20 - columns)
                    , Element.paddingEach { defaultPadding | bottom = 24 }
                    ]
                    [ Element.newTabLink
                        []
                        { url = authorLink exposition.author.id
                        , label = Element.text exposition.author.name
                        }
                    ]
                , paragraph
                    [ --, Background.color (rgb255 160 250 100)
                      Element.centerX
                    , Font.size 15
                    ]
                    [ Element.text shortAbstract ]
                ]

        Nothing ->
            Element.text "Waiting for exposition..."


viewExposition : Int -> Int -> Maybe Exposition -> Element Msg
viewExposition w columns exp =
    case exp of
        Just exposition ->
            let
                expositionPath =
                    defaultPageFromUrl exposition.url

                image =
                    case Maybe.withDefault "" exposition.thumb of
                        "" ->
                            "https://keywords.sarconference2016.net/screenshots2" ++ expositionPath ++ "/0.png"

                        _ ->
                            Maybe.withDefault "" exposition.thumb

                --amountOfText =
                --String.length shortAbstract + String.length exposition.title
                -- "smart" scaling
                imgHeight =
                    round (toFloat w / toFloat (columns + 1))

                imageHeight =
                    px imgHeight

                --px (round (toFloat w / 4))
                --px (200 + (500 // amountOfText * 20))
            in
            Element.column
                [ width fill

                --, Border.color (rgb255 0 0 0)
                --, Border.width 2
                --, Border.rounded 3
                , Element.alignTop
                ]
                [ el
                    [ --Background.color (rgb255 0 250 160)
                      height fill
                    , Element.centerX
                    ]
                    (Element.newTabLink
                        []
                        { url = exposition.url --image
                        , label =
                            Element.image
                                [ width fill
                                , height imageHeight
                                ]
                                { src = image
                                , description = "" --image ++ " preview image of the exposition"
                                }
                        }
                    )
                , if imgHeight > 250 then
                    viewTitleAuthorAbstract w columns exp

                  else
                    viewTitleAuthor w columns exp
                ]

        Nothing ->
            Element.text "Loading..."


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = ChangeUrl
        , onUrlRequest = RequestUrl
        }


subscriptions : a -> Sub Msg
subscriptions _ =
    Browser.Events.onResize WindowWasResized


authorLink : Int -> String
authorLink authorId =
    "https://www.researchcatalogue.net/profile/?person=" ++ String.fromInt authorId
