{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Noticia where

import Foundation
import Yesod.Core

getNoticiaR :: Handler Html
getNoticiaR = undefined

postNoticiaR :: Handler Html
postNoticiaR = undefined

postAttNoticiaR :: NoticiaId -> Handler Html
postAttNoticiaR alid = undefined

postDelNoticiaR :: NoticiaId -> Handler Html
postDelNoticiaR alid = undefined
