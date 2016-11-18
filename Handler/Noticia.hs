{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Noticia where

import Foundation
import Yesod.Core

-- Listas as noticias aos usuarios
getNoticiaR :: Handler Html
getNoticiaR = undefined

-- Cadastrar uma nova noticia
postNoticiaR :: Handler Html
postNoticiaR = undefined

-- Abrir noticia especifica ao usuario
getAbrirNoticiaR :: NoticiaId -> Handler Html
getAbrirNoticiaR alid = undefined 

-- Listar noticias ao jornalista, para ele poder deleta-las ou atualiza-las
getLisNoticiaR :: Handler Html
getLisNoticiaR = undefined

-- Atualizar os dados da noticia
postAttNoticiaR :: NoticiaId -> Handler Html
postAttNoticiaR alid = undefined

-- Deletar uma noticia
postDelNoticiaR :: NoticiaId -> Handler Html
postDelNoticiaR alid = undefined
