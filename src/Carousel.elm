module Carousel exposing
    ( Carousel
    , create
    , next
    , previous
    , view
    )

import Array
import Element exposing (..)
import Element.Keyed


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
    Carousel
        { internals | index = modBy (length internals) (internals.index + internals.num) }


previous : Carousel slide -> Carousel slide
previous (Carousel internals) =
    Carousel
        { internals | index = modBy (length internals) (internals.index - internals.num) }


zip =
    List.map2 Tuple.pair


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

        ourView : List ( Int, Maybe slide ) -> List ( String, Element msg )
        ourView indexedSlides =
            let
                ( idxs, slides ) =
                    List.unzip indexedSlides
            in
            zip (idxs |> List.map String.fromInt) (options.viewSlide slides)
    in
    Element.Keyed.row
        [ Element.width
            fill
        , centerX
        ]
        (ourView
            (getResearch internals options.num)
        )


length : Internals slide -> Int
length { slides } =
    List.length slides


getExposition : Internals slide -> Int -> Maybe slide
getExposition { index, slides } num =
    let
        --_ =
        --    Debug.log "slides!!!!!" slides
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


getResearch : Internals slide -> Int -> List ( Int, Maybe slide )
getResearch slides num =
    List.map (\i -> ( i, getExposition slides i )) (List.range 0 num)
