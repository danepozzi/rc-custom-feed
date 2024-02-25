module Main exposing (main, shuffleWithSeed)

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
import Html exposing (Html)
import Html.Attributes
import Http
import Json.Decode exposing (Error(..))
import Random
import Random.List exposing (shuffle)
import String.Extra
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
    | WindowWasResized Int Int


type alias Model =
    { navKey : Nav.Key
    , research : List Exposition
    , expositions : Carousel Exposition
    , parameters : Parameters
    , seed : Int
    , view : View
    , windowSize : { w : Int, h : Int }
    }


type View
    = Error
    | Carousel


type alias Parameters =
    { keyword : Maybe String
    , elements : Maybe Int
    , order : Maybe String
    }


init : ( Int, Int, Int ) -> Url -> Nav.Key -> ( Model, Cmd Msg )
init ( seed, width, height ) url navKey =
    let
        model =
            { navKey = navKey
            , research = []
            , expositions = Carousel.create [] 1
            , parameters = parametersFromAppUrl (AppUrl.fromUrl url)
            , view = Carousel
            , seed = seed
            , windowSize = { w = width, h = height }
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

        UpdateParameters p ->
            let
                _ =
                    Debug.log "parameters" p
            in
            ( { model | parameters = p }, Cmd.none )

        WindowWasResized w h ->
            ( { model | windowSize = { w = w, h = h } }, Cmd.none )


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
                    [ layout [ width fill ] (Element.text "bad query. you must provide keyword, number of elements and order. example: http://localhost:8080/?keyword=kcpedia&elements=2&order=recent") ]
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
    [ Element.row [ width fill, paddingEach { defaultPadding | left = 50 }, spacing 25 ]
        (List.concat
            [ List.map
                (columns |> (w |> viewExposition))
                exp
            , [ Input.button
                    [ width fill --<| px buttonWidth
                    , height fill
                    , Background.color (rgb255 0 255 144)

                    -- , Border.color (rgb255 0 0 0)
                    -- , Border.width 2
                    -- , Border.rounded 3
                    , Element.focused
                        [ Background.color (rgb255 0 255 255) ]
                    , centerX

                    --, moveLeft buttonWidth
                    ]
                    { onPress = Just NextExposition
                    , label = Element.text " > "
                    }
              ]
            ]
        )
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


viewTitleAuthor : Maybe Exposition -> Element Msg
viewTitleAuthor exp =
    case exp of
        Just exposition ->
            column []
                [ paragraph
                    [ height fill
                    , Font.center
                    , Font.size 20
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
                    , Font.size 20
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


viewTitleAuthorAbstract : Maybe Exposition -> Element Msg
viewTitleAuthorAbstract exp =
    case exp of
        Just exposition ->
            let
                shortAbstract =
                    String.Extra.softEllipsis 300 exposition.abstract
            in
            column []
                [ paragraph
                    [ height fill
                    , Font.center
                    , Font.size 20
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
                    , Font.size 20
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

                -- , Border.color (rgb255 0 0 0)
                -- , Border.width 2
                -- , Border.rounded 3
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
                , if imgHeight > 300 then
                    viewTitleAuthorAbstract exp

                  else
                    viewTitleAuthor exp
                ]

        Nothing ->
            Element.text "Loading..."


main : Program ( Int, Int, Int ) Model Msg
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
