{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts,
             MultiParamTypeClasses, DeriveDataTypeable, EmptyDataDecls,
             GeneralizedNewtypeDeriving, ViewPatterns, FlexibleInstances #-} -- Importante quando se usa QuasiQuoters

module Foundation where

import Yesod
import Yesod.Static
import Text.Lucius
import Data.Text
import Data.ByteString as BS
import Data.ByteString.Lazy as LBS
import System.FilePath
import Data.Time (UTCTime, getCurrentTime, showGregorian, utctDay, Day)
import Database.Persist.Postgresql
    ( ConnectionPool, SqlBackend, runSqlPool)
    
-- staticFiles "static" Indicar futuramente o  nome da pasta dos arquivos

data App = App {connPool :: ConnectionPool } -- Adicionar futuramente o type parameter {getStatic :: Static}

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Login
    nome  Text
    senha Text
    UniqueLogin nome
    deriving Show

Jornalista
    loginId     LoginId
    nome        Text
    email       Text
    nascimento  Day
    UniqueJornalista email
    deriving Show

Publicacao
    jornalistaId JornalistaId
    noticiaId NoticiaId
    deriving Show

Noticia
    nome Text
    descricao Text
    data UTCTime default=now()
    categoriaId CategoriaId
    imagem1Id ImagemId Maybe
    imagem2Id ImagemId Maybe
    imagem3Id ImagemId Maybe
    deriving Show
    
Categoria
    nome Text
    ativo Bool
    UniqueNome nome
    deriving Show

Imagem
    conteudo Text
    deriving Show

Comentario
    descricacao Text
    email Text
    noticiaId NoticiaId
    deriving Show
|]

mkYesodData "App" $(parseRoutesFile "routes")

instance Yesod App where
-- Inserindo componentes para funcionamento do Boostrap:
-- "Sobrescrevendo" a função defaultLayout. widgetToPageContent retorna uma estrutura separada em 'head' e 'body'.

    defaultLayout widget = widgetToPageContent (toWidget $(luciusFile "Static/lucius/main.lucius") >> widget) >>= \pageContent ->
    -- defaultLayout widget = widgetToPageContent widget >>= \pageContent -> 
        withUrlRenderer [hamlet|
            <!doctype html>
                <html lang="PT-BR">
                    <head>
                        <meta charset="UTF-8">
                        <title>Whatever News
                        <meta name="viewport" content="width=device-width, initial-scale=1"/>
                        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js">
                        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js">
                        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
                        ^{pageHead pageContent}
                    ^{pageBody pageContent}
        |]

instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB f = do
        master <- getYesod
        let pool = connPool master
        runSqlPool f pool

instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage
        
    