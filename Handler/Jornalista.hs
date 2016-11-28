{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Jornalista where

import Foundation
import Yesod
import Yesod.Static
import Data.Text
import Control.Applicative
import Database.Persist.Postgresql

import Yesod.Form.Bootstrap3
import Data.Time (UTCTime, getCurrentTime, showGregorian, utctDay, Day)


-- Hamlet Genéricos --------------------------------------------------------------------
footer :: Widget
footer = $(whamletFile "Templates/footer.hamlet")
-----------------------------------------------------------------------------------------

formLogin :: Form Login
formLogin = renderBootstrap $ Login
    <$> areq textField     (bfs ("Login" :: Text)) Nothing
    <*> areq passwordField (bfs ("Senha" :: Text)) Nothing
    
-- formDepto :: Form Departamento
-- formDepto = renderDivs $ Departamento <$>
--             areq textField "Nome" Nothing <*>
--             areq textField FieldSettings{fsId=Just "hident2",
--                           fsLabel="Sigla",
--                           fsTooltip= Nothing,
--                           fsName= Nothing,
--                           fsAttrs=[("maxlength","3")]} Nothing    

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
            -- (widget, enctype) <- generateFormPost formJornalista
            (widget, enctype) <- generateFormPost formJornalista
            -- (widget, enctype) <- generateFormPost $ renderBootstrap3 (BootstrapHorizontalForm (ColSm 0) (ColSm 4) (ColSm 0) (ColSm 6) (ColSm 6) (ColSm 6)) formJornalista
            -- (Text, Text, Day, Text, Text, Text)
            -- (widget, enctype) <- generateFormPost $ (BootstrapHorizontalForm (ColSm 4) (ColSm 4) (ColSm 4) (ColSm 4) (ColSm 4) (ColSm 4)) formJornalista            
            defaultLayout [whamlet|
            <div class="container">
                        <div class="row cab">
                            <div class="col-md-2 col-lg-2 logo_imagem">
                                <img class="img-responsive" src="http://66.media.tumblr.com/b560f99586e1693a8b3410a7cdd5bd1d/tumblr_inline_nhjrgyTmyQ1rp2qoz.png">
                            <div class="col-md-8 col-lg-8">
                                <h1 id="perf">Cadastre-se    
                    <div class="container">
                        <form .form-horizontal method=post action=@{CadastroR} enctype=#{enctype}>
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
                     redirect LoginR
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
                <div class="container">
                    <div class="row">
                        <div class="col-md-4">
                        <div class="col-md-4">
                            <div class="login_title">
                                <h2>PÁGINA DE <br> AUTENTICAÇÃO..?
                            <form method=post action=@{LoginR} enctype=#{enctype}>
                                ^{widget}
                                    <input class="login_submit" type="submit" value="Entrar">
                                    <a class="fake_buttom" href=@{PrincipalR}>
                                        <input class="login_submit" type="buttom" value="">
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
        
-- "LoginKey {unLoginKey = SqlBackendKey {unSqlBackendKey = 2}}"



-- Essa rota ira trazer a pagina do perfil do jornalista
getPerfilR :: Handler Html
getPerfilR = do 
    jId <- lookupSession "_ID"
    case jId of
       Just str -> do
            Just (Entity jid prophet) <- runDB $ selectFirst [JornalistaLoginId ==. (read . unpack $ str)] []
            pub <- runDB $ selectList [PublicacaoJornalistaId ==. jid] []
                    -- sequence :: [m a] -> m [a]
                    -- [IO "1", IO "2"] = IO ["1", "2"]
            noticia <- sequence $ fmap (runDB . get404 . publicacaoNoticiaId . entityVal) pub
            cats <- sequence $ fmap (runDB . get404 . noticiaCategoriaId) noticia
            notCat <- return $ Prelude.zip noticia cats
            defaultLayout $ do
                $(whamletFile "Templates/navJornalista.hamlet")
                $(whamletFile "Templates/perfil.hamlet")           
       Nothing -> redirect PrincipalR

-- Essa rota irá efetuar o logout do jornalista
postLogoutR :: Handler Html
postLogoutR = do
    deleteSession "_ID"
    redirect PrincipalR
