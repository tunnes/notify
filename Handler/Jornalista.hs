{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Jornalista where

import Foundation
import Yesod
import Data.Text
import Control.Applicative
import Database.Persist.Postgresql
import Yesod.Form.Bootstrap3
import Data.Time (UTCTime, getCurrentTime, showGregorian, utctDay, Day)

formLogin :: Form Login
formLogin = renderBootstrap $ Login
    <$> areq textField     (bfs ("Login" :: Text)) Nothing
    <*> areq passwordField (bfs ("Senha" :: Text)) Nothing

formJornalista :: Form (Text, Text, Day, Text, Text, Text)
formJornalista =  renderBootstrap $ (,,,,,)
    <$> areq textField      (bfs ("Nome Completo" :: Text))      Nothing
    <*> areq emailField     (bfs ("E-mail" :: Text))             Nothing
    <*> areq dayField       (bfs ("Data de Nascimento" :: Text)) Nothing
    <*> areq textField      (bfs ("Login" :: Text))              Nothing
    <*> areq passwordField  (bfs ("Senha" :: Text))              Nothing
    <*> areq passwordField  (bfs ("Repita a Senha" :: Text))     Nothing
    
-- Essa rota irá abrir a pagina de cadastro de jornalista
getCadastroR :: Handler Html
getCadastroR = do
            (widget, enctype) <- generateFormPost formJornalista
            defaultLayout [whamlet|
                <form method=post action=@{CadastroR} enctype=#{enctype}>
                    ^{widget}
                    <input type="submit" value="Cadastrar-se">
            |]

-- Essa rota irá receber o cadastro afim de armazena-lo no banco de dados
postCadastroR :: Handler Html
postCadastroR = do
    ((result, _), _) <- runFormPost formJornalista
    case result of 
        FormSuccess (nome, email, nascimento, login, senha, rsenha) -> do
             alid <- runDB $ insert (Login login senha)
             alid <- runDB $ insert (Jornalista alid nome email nascimento)
             defaultLayout [whamlet|
                <p>Cadastrou-se com sucesso!
            |]
        _ -> do
             defaultLayout [whamlet|
                <p>Preencha os campos corretamente!
            |]
               

-- Essa rota irá abrir a pagina de login
getLoginR :: Handler Html
getLoginR = do
            (widget, enctype) <- generateFormPost formLogin
            defaultLayout [whamlet|
                <form method=post action=@{LoginR} enctype=#{enctype}>
                    ^{widget}
                    <input type="submit" value="Entrar">
            |]

-- Essa rota irá levar os dados de login até o servidor afim de efetuar a verificação
postLoginR :: Handler Html
postLoginR = do
    ((result, _), _) <- runFormPost formLogin
    case result of 
        FormSuccess jlt -> do
            jornalista <- runDB $ selectFirst [LoginNome ==. (loginNome jlt), LoginSenha ==. (loginSenha jlt)] []
            case jornalista of
                Nothing -> redirect LoginR
                Just (Entity jid jNome) -> do
                     defaultLayout[whamlet|
                        <p> Esta logado 
                     |]
            
        _ -> do
             defaultLayout [whamlet|
                <p>Preencha os campos corretamente.
            |]
        
               

-- Essa rota irá trazer a pagina do perfil do jornalista
getPerfilR :: Handler Html
getPerfilR = undefined

-- Essa rota irá efetuar o logout do jornalista
postLogoutR :: Handler Html
postLogoutR = undefined
