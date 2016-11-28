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


-- Hamlets Genéricos --------------------------------------------------------------------
nav :: Widget 
nav = $(whamletFile "Templates/nav.hamlet")

footer :: Widget
footer = $(whamletFile "Templates/footer.hamlet")

-----------------------------------------------------------------------------------------

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
                        
                    <div class="container">
                        <form method=post action=@{CadastroR} enctype=#{enctype}>
                            ^{widget}
                            <input type="submit" value="Cadastrar-se">
                    ^{footer}
            |]

-- Essa rota irá receber o cadastro afim de armazena-lo no banco de dados
postCadastroR :: Handler Html
postCadastroR = do
    ((result, _), _) <- runFormPost formJornalista
    case result of 
        FormSuccess (nome, email, nascimento, login, senha, rsenha) -> do
        -- aqui precisa verificar se as senhas são iguais
             case senha == rsenha of
                 True -> do
                     lid <- runDB $ insert (Login login senha)
                     jorn <- runDB $ insert (Jornalista lid nome email nascimento)
                     defaultLayout [whamlet|
                        <p>Cadastrou-se com sucesso!
                     |]
                 False -> do
                      defaultLayout [whamlet|
                            <p>As senhas devem ser iguais
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
             --jogar aquii
                    <div class="container">
                        <form method=post action=@{LoginR} enctype=#{enctype}>
                            ^{widget}
                                <input type="submit" value="Entrar">
                ^{footer}
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
                    setSession "_ID" (pack $ show jid)
                    redirect PerfilR
            
        _ -> do
             defaultLayout [whamlet|
                <p>Preencha os campos corretamente.
            |]
        
               

-- Essa rota irá trazer a pagina do perfil do jornalista
getPerfilR :: Handler Html
getPerfilR = do 
    jId <- lookupSession "_ID"
    case jId of
       Just str -> do
            defaultLayout $ do
                $(whamletFile "Templates/perfil.hamlet")
       Nothing -> redirect PrincipalR
        
        


-- Essa rota irá efetuar o logout do jornalista
postLogoutR :: Handler Html
postLogoutR = do
    deleteSession "_ID"
    redirect PrincipalR
