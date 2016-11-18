{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Categoria where

import Foundation
import Yesod.Core

getCategoriaR :: Handler Html
getCategoriaR = undefined

postCategoriaR :: Handler Html
postCategoriaR = undefined

postDelCategoriaR :: CategoriaId -> Handler Html
postDelCategoriaR alid = undefined

postAttCategoriaR :: CategoriaId -> Handler Html
postAttCategoriaR alid = undefined