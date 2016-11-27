{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleContexts,
             MultiParamTypeClasses, DeriveDataTypeable, EmptyDataDecls,
             GeneralizedNewtypeDeriving, ViewPatterns, FlexibleInstances #-} -- Importante quando se usa QuasiQuoters

module Handler.Principal where

import Foundation
import Yesod
import Text.Julius
import System.FilePath
import Yesod.Static

-- Hamlets Genéricos -------------------------------------------------------------------------------------------------------
header :: Widget
header = $(whamletFile "Templates/header.hamlet")

nav :: Widget
nav = $(whamletFile "Templates/nav.hamlet")

footer :: Widget
footer = $(whamletFile "Templates/footer.hamlet")

---------------------------------------------------------------------------------------------------------------------------

getPrincipalR :: Handler Html
getPrincipalR = do
    (n1:n2:n3:ns) <- runDB $ selectList [] [Asc NoticiaData, LimitTo 9]
    defaultLayout $ do
        -- toWidgetHead $(juliusFile "Static/julius/principal.julius") >>
        -- runDB $ selectList [] [Asc NoticiaData] >>= \(n1:n2:n3:ns) ->
        addScript (StaticR julius_principal_js)
        $(whamletFile "Templates/principal.hamlet")

{-
upload
https://github.com/yesodweb/yesod/wiki/Cookbook-File-upload

você vai ter que criar uma rota para arquivos dinâmicos

    ---- no arquivo de rotas
    
    imagem/#ImagemNome  --onde ImagemNome é do tipo String (obs: a talvez tenha que usar text e converter para string)
    
    ---  No rotas implementadas
    
    getImageR imagemNome = do
        -- ... save image data to disk somewhere
        sendFile typeJpeg imagemNome  -- Assinatura https://hackage.haskell.org/package/yesod-0.4.1/docs/Yesod-Handler.html#v:sendFile
        
    digamos que salvei uma imagem ms.jpeg
    no banco salvaria o nome como text "ms.jpeg"
    quando der o select "img <- runDB $ selectList [ImagemNome .== imagemNome]"
    @{getImageR img}
-}