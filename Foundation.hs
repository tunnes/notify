{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts, TypeSynonymInstances,
             MultiParamTypeClasses, DeriveDataTypeable, EmptyDataDecls,
             GeneralizedNewtypeDeriving, ViewPatterns, FlexibleInstances #-} -- Importante quando se usa QuasiQuoters

module Foundation where

import Yesod
import Yesod.Static
import Yesod.Core.Handler
import Text.Lucius
import Data.Text
import Control.Applicative
import Data.ByteString as BS
import Data.ByteString.Lazy as LBS
import System.FilePath
import Data.Time (UTCTime, getCurrentTime, showGregorian, utctDay, Day)
import Database.Persist.Postgresql
    ( ConnectionPool, SqlBackend, runSqlPool)
    
staticFiles "Static" --Indicar futuramente o  nome da pasta dos arquivos

data App = App {getStatic :: Static, connPool :: ConnectionPool } -- Adicionar futuramente o type parameter {getStatic :: Static}

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
    descricao Textarea
    data UTCTime default=now()
    categoriaId CategoriaId
    imagemId ImagemId
    deriving Show
    
Categoria
    nome Text
    ativo Bool
    UniqueNome nome
    deriving Show

Imagem
    conteudo String  
    deriving Show

|]

mkYesodData "App" $(parseRoutesFile "routes")

type Form a = Html -> MForm Handler (FormResult a, Widget)

instance Yesod App where

-- Inserindo componentes para funcionamento do Boostrap ---------------------------------------------------------------------------------------
-- Com uma função anonima 'Lambda' e realizada a sobrescrita da função defaultLayout ela recebe um widgetToPageContent e retorna uma estrutura 
-- separada em 'head' e 'body', com isto conseguimos fixar uma unica folha de estilos e todas as 'meta tags' utilizadas no projeto. 

    defaultLayout widget = widgetToPageContent (toWidget $(luciusFile "Static/lucius/main.lucius") >> widget) >>= \pageContent ->
        withUrlRenderer [hamlet|
            <!doctype html>
                <html lang="PT-BR">
                    <head>
                        <meta charset="UTF-8">
                        <title>Whatever News
                        <meta name="viewport" content="width=device-width, initial-scale=1"/>
                        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js">
                        <link rel="shortcut icon" type="image/png" href=@{StaticR fav_whatever_png}/>
                        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js">
                        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
                        ^{pageHead pageContent}
                    ^{pageBody pageContent}
        |]
        
    authRoute _                       = Just LoginR
    isAuthorized LoginR _             = return Authorized
    isAuthorized (AbrirNoticiaR _) _  = return Authorized
    isAuthorized TodasNoticiaR _      = return Authorized
    isAuthorized CadastroR _          = return Authorized
    isAuthorized _ _                  = estaAutenticado
    
estaAutenticado :: Handler AuthResult -- Funcao que verifica sessao
estaAutenticado = do
    msu <- lookupSession "_ID"
    case msu of
        Just _  -> return Authorized
        Nothing -> return AuthenticationRequired
        
instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB f = do
        master <- getYesod
        let pool = connPool master
        runSqlPool f pool


instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage