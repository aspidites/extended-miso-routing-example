{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Data.Proxy
import Miso
import Servant.API
import Servant.Links

import Control.Lens (Lens', lens, (.=))

-- | Keep track of current URL in the app's model
data Model = Model { _uri :: URI } deriving (Show, Eq)

uri :: Lens' Model URI
uri = lens _uri $ \model _uri -> model { _uri }

-- | The only action this particular app can do is push URIs to history and
-- respond to uris that were popped.
data Action = PushState URI | PopState URI | NoOp deriving (Show, Eq)

-- | Type-safe routes
type API = Home :<|> About :<|> Users
type Home = View Action
type About = "about" :> View Action
type Users = "users" :> View Action

api :: Proxy API
api = Proxy

home :: Proxy Home
home = Proxy

about :: Proxy About
about = Proxy

users :: Proxy Users
users = Proxy

main :: IO ()
main = do
  currentURI <- getCurrentURI
  startApp App 
    { initialAction = NoOp
    , model = Model currentURI
    , update = fromTransition . updateModel
    , view = viewModel
    , events = defaultEvents
    , subs = [ uriSub PopState ]
    , mountPoint = Nothing
    , logLevel = Off
    }

updateModel :: Action -> Transition Action Model ()
updateModel action =
  case action of
    -- By listining to URI events, we can keep the app's model in sync with the
    -- browser's history
    PopState u -> do
      uri .= u
    PushState u -> scheduleIO_ $ pushURI u
    NoOp -> pure ()

viewModel :: Model -> View Action
viewModel model =
  -- This part of the UI remains static, not responding to URI changes
  div_ []
    [ nav_ []
      [ li_ []
        [ a_ [ href_ "#", onClick $ linkTo home ]
          [ text "Home" ]
        ]
      , li_ []
        [ a_ [ href_ "#", onClick $ linkTo about ]
          [ text "About" ]
        ]
      , li_ []
        [ a_ [ href_ "#", onClick $ linkTo users ]
          [ text "Users" ]
        ]
      ]
    -- this is the part of the UI that renders differently based on the current
    -- URI
    , view
    ]
  where
    linkTo p = PushState (linkURI (safeLink api p))
    view = either notFound_ id $ runRoute api handlers _uri model
    handlers = home_ :<|> about_ :<|> users_
    home_ _ = h2_ [] [ text "Home" ]
    about_ _ = h2_ [] [ text "About" ]
    users_ _ = h2_ [] [ text "Users" ]
    notFound_ _ = h2_ [] [ text "Where are you going?" ]

