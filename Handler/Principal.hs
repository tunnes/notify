{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Principal where

import Foundation
import Yesod.Core

getPrincipalR :: Handler Html
getPrincipalR = defaultLayout $ do
    setTitle "Whatever News"
    $(whamletFile "Templates/principal.hamlet")
