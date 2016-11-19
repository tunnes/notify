{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Principal where

import Foundation
import Yesod.Core

getPrincipalR :: Handler Html
getPrincipalR = defaultLayout $ do
    setTitle "Whatever News"
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