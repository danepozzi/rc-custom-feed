module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Carousel exposing (Carousel)
import Decode exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Http
import Json.Decode exposing (Error(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), (<?>), Parser)


urlParser : Parser (String -> a) a
urlParser =
    Url.Parser.string


type Msg
    = NoOp
    | ChangeUrl Url
    | RequestUrl Browser.UrlRequest
    | NextExposition
    | DataReceived (Result Http.Error (List Exposition))


type alias Model =
    { navKey : Nav.Key
    , research : List Exposition
    , route : Maybe String
    , expositions : Carousel Exposition
    , display : Int
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    ( { navKey = navKey
      , research = []
      , route = Url.Parser.parse urlParser url
      , expositions = Carousel.create [] 1
      , display = 3
      }
    , sendQuery (Maybe.withDefault "Nothing" (Url.Parser.parse urlParser url))
    )



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
                    Debug.log "http-request" expositions
            in
            ( { model | expositions = Carousel.create expositions model.display }, Cmd.none )

        DataReceived (Err error) ->
            let
                _ =
                    Debug.log "error" error
            in
            ( model, Cmd.none )

        NextExposition ->
            ( { model | expositions = Carousel.next model.expositions }, Cmd.none )


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
    { title = "custom-feed"
    , body =
        [ layout [ width fill ]
            (Carousel.view
                { carousel = model.expositions
                , onNext = NextExposition
                , viewSlide = viewResearch
                , num = model.display - 1
                }
            )
        ]
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
                    [ width fill ]
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
        , onUrlChange = ChangeUrl
        , onUrlRequest = RequestUrl
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
