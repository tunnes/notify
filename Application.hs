{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE ViewPatterns         #-}
{-# LANGUAGE QuasiQuotes          #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}
module Application where

import Foundation
import Yesod.Core

-- Importando os handlers
import Handler.Principal
import Handler.Categoria
import Handler.Comentario
import Handler.Jornalista
import Handler.Noticia

mkYesodDispatch "App" resourcesApp
