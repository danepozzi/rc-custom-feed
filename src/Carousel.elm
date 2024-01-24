module Carousel exposing
    ( Carousel
    , create
    , next
    , view
    )

import Array
import Element exposing (..)


type Carousel slide
    = Carousel (Internals slide)


type alias Internals slide =
    { index : Int
    , slides : List slide
    , num : Int
    }


create : List slide -> Int -> Carousel slide
create slides num =
    Carousel
        { index = 0
        , slides = slides
        , num = num
        }


next : Carousel slide -> Carousel slide
next (Carousel internals) =
    let
        _ =
            Debug.log "internals" internals
    in
    Carousel
        { internals | index = modBy (length internals) (internals.index + internals.num) }


view :
    { carousel : Carousel slide
    , onNext : msg
    , viewSlide : List (Maybe slide) -> List (Element msg)
    , num : Int
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
        (options.viewSlide
            (getResearch internals options.num)
        )


length : Internals slide -> Int
length { slides } =
    List.length slides


getExposition : Internals slide -> Int -> Maybe slide
getExposition { index, slides } num =
    let
        _ =
            Debug.log "slides!!!!!" slides

        l =
            List.length slides

        which =
            if l < 1 then
                0

            else
                modBy (List.length slides) (index + num)

        --?
    in
    Array.fromList slides
        |> Array.get which


getResearch : Internals slide -> Int -> List (Maybe slide)
getResearch slides num =
    List.map (getExposition slides) (List.range 0 num)
