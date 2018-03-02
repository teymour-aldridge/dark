module TestAutocomplete exposing (all)

-- tests
import Test exposing (..)
import Expect exposing (Expectation)

-- builtins
-- import Set

-- libs
import List.Extra as LE

-- dark
import Autocomplete exposing (..)
import Types exposing (..)
import Defaults


d : String -> List (() -> Bool) -> Test
d s fs = describe s (List.indexedMap
                       (\i f ->
                          test
                          ("test " ++ (toString i))
                          (\_ -> Expect.true "" (f ())))
                       fs
                    )


all : Test
all =
  let completes =
        List.map (\(name,tipe) ->
                    { name = name
                    , parameters = [{ name = "x"
                                    , tipe = tipe
                                    , block_args = []
                                    , optional = False
                                    , description = ""
                                    }]
                    , returnTipe = TBool
                    , description = ""
                    , infix = True
                    })
          [ ("Twit::somefunc", TObj)
          , ("Twit::someOtherFunc", TObj)
          , ("Twit::yetAnother", TObj)
          , ("+", TInt)
          , ("Int::add", TInt)
          , ("Dict::keys", TObj)
          , ("List::head", TList)
          , ("withlower", TObj)
          , ("withLower", TObj)
          , ("SomeModule::withLower", TObj)
          , ("SomeOtherModule::withlower", TObj)
          ]
      m = Defaults.defaultModel Defaults.defaultEditor
      create () = init completes |> regenerate m
  in
  describe "autocomplete"
    [ d "sharedPrefix"
      [ \_ -> sharedPrefixList ["aaaab", "aab", "aaxb"] == "aa"
      , \_ -> sharedPrefixList ["abcdd", "abcdde"] == "abcdd"
      , \_ -> sharedPrefixList ["abcdd", "bcddee"] == ""
      ]
    , d "query" -- numbered from 0
      -- Empty autocomplete doesn't highlight
      [ \_ -> (create ())
      |> .index
      |> (==) -1

      -- Press a letter from the selected entry keeps the entry selected
      , \_ -> create ()
      |> selectDown
      |> selectDown
      |> setQuery "T"
      |> highlighted
      |> Maybe.map asName
      |> (==) (Just "Twit::someOtherFunc")

      -- Returning to empty unselects
      , \_ -> create ()
      |> setQuery "lis"
      |> setQuery ""
      |> highlighted
      |> (==) Nothing

      , \_ -> create ()
      |> setQuery "Twit::somefunc"
      |> setQuery "Twit::some"
      |> selectDown
      |> highlighted
      |> Maybe.map asName
      |> Debug.log "actual"
      |> (==) (Just "Twit::someOtherFunc")

      -- Lowercase search still finds uppercase results
      , \_ -> create ()
      |> update m (ACSetQuery "lis")
      |> .completions
      |> List.concat
      |> List.map asName
      |> (==) ["List::head"]

      -- Search finds multiple prefixes
      , \_ -> create ()
      |> setQuery "twit::"
      |> .completions
      |> List.concat
      |> List.map asName
      |> (==) ["Twit::somefunc", "Twit::someOtherFunc", "Twit::yetAnother"]

      -- Search finds only prefixed
      , \_ -> create ()
      |> setQuery "twit::y"
      |> .completions
      |> List.concat
      |> List.map asName
      |> (==) ["Twit::yetAnother"]

      -- Search anywhere
      , \_ -> create ()
      |> setQuery "Another"
      |> .completions
      |> List.concat
      |> List.map asName
      |> (==) ["Twit::yetAnother"]

      -- Show results when the only option is the setQuery
      , \_ -> create ()
      |> setQuery "List::head"
      |> .completions
      |> List.concat
      |> List.map asName
      |> List.length
      |> (==) 1

      -- Scrolling down a bit works
      , \_ -> create ()
      |> setQuery "Twit"
      |> selectDown
      |> selectDown
      |> .index
      |> (==) 2

      -- Scrolling loops one way
      , \_ -> create ()
      |> setQuery "Twit"
      |> selectDown
      |> selectDown
      |> selectDown
      |> .index
      |> (==) 0

      -- Scrolling loops the other way
      , \_ -> create ()
      |> setQuery "Twit"
      |> selectDown
      |> selectUp
      |> selectUp
      |> .index
      |> (==) 2

      -- Scrolling loops the other way without going forward first
      , \_ -> create ()
      |> setQuery "Twit"
      |> selectUp
      |> selectUp
      |> .index
      |> (==) 1

      -- Scrolling backward works if we haven't searched yet
      , \_ -> create ()
      |> selectUp
      |> selectUp
      |> .index
      |> (==) 9

      -- Don't highlight when the list is empty
      , \_ -> create ()
      |> setQuery "Twit"
      |> selectDown
      |> selectDown
      |> setQuery "Twitxxx"
      |> .index
      |> (==) -1

      -- Filter by method signature for typed values
      -- , \_ -> create ()
      -- |> forLiveValue {value="[]", tipe=TList,json="[]", exc=Nothing}
      -- |> setQuery ""
      -- |> .completions
      -- |> List.map asName
      -- |> Set.fromList
      -- |> (==) (Set.fromList ["List::head"])

      -- Show allowed fields for objects
      -- , \_ -> create ()
      -- |> forLiveValue {value="5", tipe=TInt, json="5", exc=Nothing}
      -- |> setQuery ""
      -- |> .completions
      -- |> List.map asName
      -- |> Set.fromList
      -- |> (==) (Set.fromList ["Int::add", "+"])

      -- By default the list shows results
      , \_ -> create ()
      |> setQuery ""
      |> .completions
      |> List.concat
      |> List.length
      |> (/=) 0

      -- ordering: startsWith, then case match, then case insensitive match
      , \_ -> create ()
      |> setQuery "withL"
      |> .completions
      |> List.map (List.map asName)
      |> (==) [ ["withLower"]
              , ["withlower"]
              , ["SomeModule::withLower"]
              , ["SomeOtherModule::withlower"]
              ]

      ]
    ]


