module Carousel exposing
    ( Carousel
    , create
    , next
    , view
    )

import Array
import Element exposing (..)
import Html exposing (..)


type Carousel slide
    = Carousel (Internals slide)


type alias Internals slide =
    { index : Int
    , slides : List slide
    }


create : List slide -> Carousel slide
create slides =
    Carousel
        { index = 0
        , slides = slides
        }


next : Carousel slide -> Carousel slide
next (Carousel internals) =
    Carousel
        { internals | index = modBy (length internals) (internals.index + 1) }


view :
    { carousel : Carousel slide
    , onNext : msg
    , viewSlide : Maybe slide -> Element msg
    }
    -> Element msg
view options =
    let
        (Carousel internals) =
            options.carousel
    in
    Element.wrappedRow
        [ Element.width
            (fill
                |> maximum 800
            )
        , centerX
        ]
        [ options.viewSlide (current internals) ]


length : Internals slide -> Int
length { slides } =
    List.length slides


current : Internals slide -> Maybe slide
current { index, slides } =
    Array.fromList slides
        |> Array.get index
