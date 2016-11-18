{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE ViewPatterns      #-}
{-# LANGUAGE QuasiQuotes       #-} -- Importante quando se usa QuasiQuoters

module Foundation where

import Yesod

data App = App

mkYesodData "App" $(parseRoutesFile "routes")

instance Yesod App where
-- Inserindo componentes para funcionamento do Boostrap:
-- "Sobrescrevendo" a função defaultLayout. widgetToPageContent retorna uma estrutura separada em 'head' e 'body'.

    defaultLayout widget = widgetToPageContent widget >>= \pageContent -> 
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
        
    