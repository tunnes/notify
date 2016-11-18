{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts,
             MultiParamTypeClasses, DeriveDataTypeable, EmptyDataDecls,
             GeneralizedNewtypeDeriving, ViewPatterns, FlexibleInstances #-} -- Importante quando se usa QuasiQuoters

module Foundation where

import Yesod
import Yesod.Static
import Text.Lucius
import Data.Text
import Database.Persist.Postgresql
    ( ConnectionPool, SqlBackend, runSqlPool)
    
-- staticFiles "static" Indicar futuramente o  nome da pasta dos arquivos

data App = App {connPool :: ConnectionPool } -- Adicionar futuramente o type parameter {getStatic :: Static}

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|

Inicio
    conf Text
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
        
    