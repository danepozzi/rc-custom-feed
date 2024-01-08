module Decode exposing (Exposition, expositionsDecoder)

import Json.Decode exposing (..)


type alias Exposition =
    { abstract : String

    --, defaultPage : String
    --, id : Int
    --, keywords : List String
    --, publication : List Publication
    , author : Author
    , thumb : Maybe String
    , title : String

    --, type_ : String
    }


type alias Author =
    { id : Int
    , name : String
    }


type alias Publication =
    { id : Int
    , name : String
    }


publicationDecoder : Json.Decode.Decoder Publication
publicationDecoder =
    Json.Decode.map2 Publication
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)


authorDecoder : Json.Decode.Decoder Author
authorDecoder =
    Json.Decode.map2 Author
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)


expositionDecoder : Json.Decode.Decoder Exposition
expositionDecoder =
    Json.Decode.map4 Exposition
        (Json.Decode.field "abstract" Json.Decode.string)
        --(Json.Decode.field "default-page" Json.Decode.string)
        --(Json.Decode.field "id" Json.Decode.int)
        --(Json.Decode.field "keywords" <| Json.Decode.list Json.Decode.string)
        --(Json.Decode.field "published_in" <| Json.Decode.list publicationDecoder)
        (Json.Decode.field "author" authorDecoder)
        (Json.Decode.maybe (Json.Decode.field "thumb" Json.Decode.string))
        --(Json.Decode.field "meta-data-page" Json.Decode.string)
        (Json.Decode.field "title" Json.Decode.string)


expositionsDecoder : Json.Decode.Decoder (List Exposition)
expositionsDecoder =
    Json.Decode.list expositionDecoder
