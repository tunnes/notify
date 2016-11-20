{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Comentario where

import Foundation
import Yesod.Core
import Control.Applicative
import Yesod.Form.Bootstrap3
import Database.Persist.Postgresql

{--comentarioForm :: Form Comentario
comentarioForm = renderDivs $ Comentario
     <$> areq emailField (bfs ("E-mail" :: Text)) Nothing 
     <*> areq textareaField (bfs ("Comentário" :: Text)) Nothing --}

-- Recebe um post com o comentario e o ID da noticia no qual receberá o comentário
postComentarioR :: NoticiaId -> Handler Html
postComentarioR alid = undefined