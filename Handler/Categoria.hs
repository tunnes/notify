{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Categoria where

import Foundation
import Yesod.Core
import Data.Text
import Yesod.Form
import Control.Applicative
import Yesod.Form.Bootstrap3
import Database.Persist.Postgresql

-- Hamlet Genéricos --------------------------------------------------------------------
--footer :: Widget
--footer = $(whamletFile "Templates/footer.hamlet")
-----------------------------------------------------------------------------------------

-- formCategoria :: Form (Text)
-- formCategoria = renderBootstrap $ (,)
--     <$> areq textField     (bfs ("Nome da categoria" :: Text)) Nothing



-- Essa rota irá listar categorias ao Jornalista, para que ele possa atualiza-las ou deleta-las
-- getCategoriaR :: Handler Html
-- getCategoriaR =  do
--             (widget, enctype) <- generateFormPost formCategoria
--             defaultLayout [whamlet|
--                     <div class="container">
--                         <form method=post action=@{AttCategoriaR} enctype=#{enctype}>
--                             ^{widget}
--                             <input type="submit" value="Cadastrar">
--                     ^{footer}
--             |]

-- Recebe um post com as informações de uma nova categoria cadastrada 
-- Com a finalidade de armazena-la no banco.

getCategoriaR :: Handler Html
getCategoriaR =  undefined

postCategoriaR :: Handler Html
postCategoriaR = undefined

-- Recebe um post com o id da categoria a ser deletada
postDelCategoriaR :: CategoriaId -> Handler Html
postDelCategoriaR alid = undefined

-- Recebe um post com o id da categoria a ser atualizada
postAttCategoriaR :: CategoriaId -> Handler Html
postAttCategoriaR alid = undefined