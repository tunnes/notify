{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Comentario where

import Foundation
import Yesod.Core

postComentarioR :: NoticiaId -> Handler Html
postComentarioR alid = undefined