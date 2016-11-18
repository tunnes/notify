{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Jornalista where

import Foundation
import Yesod.Core

-- Essa rota irá abrir a pagina de cadastro de jornalista
getCadastroR :: Handler Html
getCadastroR = undefined

-- Essa rota irá receber o cadastro afim de armazena-lo no banco de dados
postCadastroR :: Handler Html
postCadastroR = undefined

-- Essa rota irá abrir a pagina de login
getLoginR :: Handler Html
getLoginR = undefined

-- Essa rota irá levar os dados de login até o servidor afim de efetuar a verificação
postLoginR :: Handler Html
postLoginR = undefined

-- Essa rota irá trazer a pagina do perfil do jornalista
getPerfilR :: Handler Html
getPerfilR = undefined

-- Essa rota irá efetuar o logout do jornalista
postLogoutR :: Handler Html
postLogoutR = undefined
