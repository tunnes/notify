{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Handler.Noticia where

import Foundation
import Yesod
import Data.Text
import System.FilePath
import Control.Applicative 
import Yesod.Form.Bootstrap3
import Data.Time (UTCTime, getCurrentTime, showGregorian, utctDay, Day)

{-- uploadForm :: Html -> MForm App App (FormResult (FileInfo, Maybe Textarea, UTCTime), Widget)
uploadForm = renderDivs $ (,,)
    <$> fileAFormReq "Image file"
    <*> aopt textareaField "Image description" Nothing
    <*> aformM (liftIO getCurrentTime) --}

formNoticia :: Form (Text,Textarea,CategoriaId, FileInfo)
formNoticia = renderBootstrap $ (,,,)
    <$> areq textField                (bfs ("Titulo" :: Text))     Nothing 
    <*> areq textareaField            (bfs ("Descrição" :: Text))  Nothing
    <*> areq (selectField categorias) (bfs ("Categoria" :: Text))  Nothing
    <*> fileAFormReq                  (bfs ("Imagem" :: Text)) 
    where
        categorias :: Handler (OptionList CategoriaId)
        categorias = do
            itens <- runDB $ selectList [CategoriaAtivo ==. True] [Asc CategoriaNome]
            optionsPairs $ Prelude.map (\cat -> (categoriaNome $ entityVal cat, entityKey cat)) itens

-- Listas as noticias aos usuarios
getNoticiaR :: Handler Html
getNoticiaR = do
            (widget, enctype) <- generateFormPost formNoticia
            defaultLayout [whamlet|
                <form method=post action=@{NoticiaR} enctype=#{enctype}>
                    ^{widget}
                    <input type="submit" value="Cadastrar Noticia">
            |]--}

-- Cadastrar uma nova noticia
postNoticiaR :: Handler Html
postNoticiaR = do
    ((result, _), _) <- runFormPost formNoticia
    case result of
        FormSuccess (titulo,descricao,categoria,imagem) -> do
            writeToServer imagem  
            alid <- runDB $ insert (Imagem (fileName imagem))
            now <- liftIO getCurrentTime
            alid <- runDB $ insert (Noticia titulo descricao now categoria alid)
            defaultLayout [whamlet|
                <p>Noticia cadastrada com sucesso!
            |]
        _ -> do
            defaultLayout [whamlet|
                <p>Preencha os dados corretamente!
            |]
            redirect NoticiaR


-- Abrir noticia especifica ao usuario  ------------------------------------------------------------------------ 
getAbrirNoticiaR :: NoticiaId -> Handler Html
getAbrirNoticiaR noticiaID = do
    Just noticia <- runDB $ get noticiaID 
    defaultLayout $ do
        [whamlet|
            <h2> #{noticiaNome noticia}
        |]
        
----------------------------------------------------------------------------------------------------------------
        
-- Listar noticias ao jornalista, para ele poder deleta-las ou atualiza-las
getLisNoticiaR :: Handler Html
getLisNoticiaR = undefined

-- Atualizar os dados da noticia
postAttNoticiaR :: NoticiaId -> Handler Html
postAttNoticiaR alid = undefined

-- Deletar uma noticia
postDelNoticiaR :: NoticiaId -> Handler Html
postDelNoticiaR alid = undefined

-- Depois eu comento detalhadamente o que esse código faz

writeToServer :: FileInfo -> Handler FilePath
writeToServer file = do
    let filename = unpack $ fileName file
        path = imageFilePath filename
    liftIO $ fileMove file path
    return filename

imageFilePath :: String -> FilePath
imageFilePath f = uploadDirectory </> f

uploadDirectory :: FilePath
uploadDirectory = "Static/img"
