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


{--Formulários
formCategoria :: Form Categoria 
formCategoria = renderDivs $ Categoria
    <$> areq textField (bfs ("Nome da Categoria" :: Text)) Nothing
    <*> areq checkBoxField (bfs ("Visivel" :: Text))  Nothing --}
    



-- Essa rota irá listar categorias ao Jornalista, para que ele possa atualiza-las ou deleta-las
getCategoriaR :: Handler Html
getCategoriaR = undefined

-- Recebe um post com as informações de uma nova categoria cadastrada 
-- Com a finalidade de armazena-la no banco.
postCategoriaR :: Handler Html
postCategoriaR = undefined

-- Recebe um post com o id da categoria a ser deletada
postDelCategoriaR :: CategoriaId -> Handler Html
postDelCategoriaR alid = undefined

-- Recebe um post com o id da categoria a ser atualizada
postAttCategoriaR :: CategoriaId -> Handler Html
postAttCategoriaR alid = undefined