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

--  Visualizar Noticia ---------------------------------------------------------------------------------------------
--  Estes são os 'Widgets' genericos utilizados dentro dos 'Templates', aqui estamos os utilizando pois assim 
--  conseguimos modularizar a pagina que sera renderizada ao no lado do cliente.

header :: Widget
header = $(whamletFile "Templates/header.hamlet")

nav :: Widget
nav = $(whamletFile "Templates/nav.hamlet")

footer :: Widget
footer = $(whamletFile "Templates/footer.hamlet")

--------------------------------------------------------------------------------------------------------------------

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
            imagemnome <- writeToServer imagem
            alid <- runDB $ insert (Imagem $ imagemnome)
            now <- liftIO getCurrentTime
            noid <- runDB $ insert (Noticia titulo descricao now categoria alid)
            defaultLayout [whamlet|
                <p>Noticia cadastrada com sucesso!
            |]
        _ -> do
            defaultLayout [whamlet|
                <p>Preencha os dados corretamente!
            |]
            redirect NoticiaR

--  Visualizar Noticia --------------------------------------------------------------------------------------------- 
--  Esta função recebe um ID numerico de uma noticia e retorna uma pagina com detalhes da noticia expandida, para
--  conseguir estes detalhes ela faz uma consulta ao banco utilizando a função get que retorna um Maybe Noticia
--  o retorno entra dentro do pathern matching Just noticia ai temos uma noticia 'variavel' =D   

getAbrirNoticiaR :: NoticiaId -> Handler Html
getAbrirNoticiaR noticiaID = do
    Just noticia <- runDB $ get noticiaID 
    defaultLayout $ do
        $(whamletFile "Templates/noticiaCorpo.hamlet")
        
--------------------------------------------------------------------------------------------------------------------


--  Visualizar Todas Noticias -------------------------------------------------------------------------------------- 
--  Esta função realiza uma consulta e retorna uma lista de noticias com uma informações resumidas de cada uma, 
--  foi utilizado o selectList para realizar a consulta e os bons e velhos widgets de header e footer, ao clicar 
--  em ver mais o usuario sera redirecionado para a pagina de visualização de noticia.

getTodasNoticiaR :: Handler Html
getTodasNoticiaR = do
    ns <- runDB $ selectList [] [Desc NoticiaData]
    is <- runDB $ selectList [] [Desc ImagemId]
    let tupla = (ns,is)
    defaultLayout $ do
        $(whamletFile "Templates/noticiaTodas.hamlet")
    where
        diretorio = "static/img/"
        
--------------------------------------------------------------------------------------------------------------------    
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
