module Main exposing (..)

import NativeUi as Ui exposing (Node)
import NativeUi.Style as Style exposing (defaultTransform)
import NativeUi.Elements as Elements exposing (..)
import NativeUi.Events exposing (..)
import NativeUi.ListView
import NativeUi.Properties
import WebSocket


main : Program Never Model Msg
main =
    Ui.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { input : String
    , messages : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], Cmd.none )



-- UPDATE


type Msg
    = Input String
    | Send
    | NewMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { input, messages } =
    case msg of
        Input newInput ->
            ( Model newInput messages, Cmd.none )

        Send ->
            ( Model "" messages, WebSocket.send "ws://echo.websocket.org" input )

        NewMessage str ->
            ( Model input (str :: messages), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://echo.websocket.org" NewMessage



-- VIEW


textView : String -> Node Msg
textView str =
    text [] [ Ui.string str ]


chatView : List String -> String -> Node Msg
chatView messages input =
    Elements.view
        [ Ui.style
            [ Style.paddingHorizontal 12
            , Style.paddingVertical 24
            ]
        ]
        [ Elements.view
            [ Ui.style
                [ Style.backgroundColor "#fff"
                , Style.padding 24
                , Style.borderRadius 4
                , Style.shadowColor "#000"
                , Style.shadowOpacity 0.15
                , Style.shadowOffset 1 1
                , Style.shadowRadius 5
                ]
            ]
            [ Elements.view
                [ Ui.style
                    [ Style.justifyContent "space-between"
                    , Style.flexDirection "row"
                    ]
                ]
                [ textView "Chat-Example"
                , textView "1 people"
                ]
            , NativeUi.ListView.listView (NativeUi.ListView.updateDataSource messages NativeUi.ListView.emptyDataSource) textView []
            , textInput [ NativeUi.Properties.key input ] ([ textView input ])
            , buttonView Send 20 20 "Send"
            ]
        ]


buttonView : Msg -> Float -> Float -> String -> Node Msg
buttonView msg topPadding padding content =
    Elements.view
        [ Ui.style
            [ Style.paddingTop (topPadding - padding) ]
        ]
        [ Elements.view
            [ Ui.style
                [ Style.padding padding
                , Style.borderRadius 100
                , Style.backgroundColor "#fff"
                , Style.shadowColor "#000"
                , Style.shadowOpacity 0.5
                , Style.shadowOffset 1 1
                , Style.shadowRadius 100
                , Style.alignSelf "center"
                ]
            ]
            [ text
                [ Ui.style [ Style.fontSize 18 ]
                , onPress msg
                ]
                [ Ui.string content ]
            ]
        ]


view : Model -> Node Msg
view { input, messages } =
    Elements.view
        [ Ui.style
            [ Style.backgroundColor "#eee"
            , Style.justifyContent "space-between"
            , Style.height Native.NativeUi.Dimensions.windowHeight
            , Style.paddingBottom 24
            ]
        ]
        [ chatView messages input ]
