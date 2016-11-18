{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Comentario where

import Foundation
import Yesod.Core

-- Recebe um post com o comentario e o ID da noticia no qual receberá o comentário
postComentarioR :: NoticiaId -> Handler Html
postComentarioR alid = undefined