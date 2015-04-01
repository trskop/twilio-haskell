{-#LANGUAGE MultiParamTypeClasses #-}
{-#LANGUAGE OverloadedStrings #-}
{-#LANGUAGE ViewPatterns #-}

module Twilio.UsageTrigger
  ( -- * Resource
    UsageTrigger(..)
  , Twilio.UsageTrigger.get
  ) where

import Control.Applicative
import Control.Monad
import Data.Aeson
import Data.Maybe
import Data.Time.Clock
import Network.URI

import Control.Monad.Twilio
import Twilio.Internal.Parser
import Twilio.Internal.Request
import Twilio.Internal.Resource as Resource
import Twilio.Types

{- Resource -}

data UsageTrigger = UsageTrigger
  { sid            :: !UsageTriggerSID
  , dateCreated    :: !UTCTime
  , dateUpdated    :: !UTCTime
  , accountSID     :: !AccountSID
  , friendlyName   :: !String
  , recurring      :: !(Maybe String)
  , usageCategory  :: !String
  , triggerBy      :: !String
  , triggerValue   :: !String
  , currentValue   :: !String
  , usageRecordURI :: !URI
  , callbackURL    :: !(Maybe String)
  , callbackMethod :: !String
  , dateFired      :: !(Maybe String)
  , uri            :: !URI
  } deriving (Eq, Show)

instance FromJSON UsageTrigger where
  parseJSON (Object v) = UsageTrigger
    <$>  v .: "sid"
    <*> (v .: "date_created"     >>= parseDateTime)
    <*> (v .: "date_updated"     >>= parseDateTime)
    <*>  v .: "account_sid"
    <*>  v .: "friendly_name"
    <*>  v .: "recurring"
    <*>  v .: "usage_category"
    <*>  v .: "trigger_by"
    <*>  v .: "trigger_value"
    <*>  v .: "current_value"
    <*> (v .: "usage_record_uri" <&> parseRelativeReference
                                 >>= maybeReturn)
    <*>  v .: "callback_url"
    <*>  v .: "callback_method"
    <*>  v .: "date_fired"
    <*> (v .: "uri"              <&> parseRelativeReference
                                 >>= maybeReturn)
  parseJSON _ = mzero

instance Get1 UsageTriggerSID UsageTrigger where
  get1 (getSID -> sid) = request (fromJust . parseJSONFromResponse) =<< makeTwilioRequest
    ("/Usage/Triggers/" ++ sid ++ ".json")

-- | Get a 'UsageTrigger' by 'UsageTriggerSID'.
get :: Monad m => UsageTriggerSID -> TwilioT m UsageTrigger
get = Resource.get