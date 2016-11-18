{-# LANGUAGE OverloadedStrings, QuasiQuotes,
             TemplateHaskell #-}
import Application () -- for YesodDispatch instance
import Foundation
import Yesod.Core
import Control.Monad.Logger (runStdoutLoggingT)
import Database.Persist.Postgresql

connStr :: ConnectionString
connStr = "dbname=d49keoi3t0rpjd host=ec2-23-23-208-32.compute-1.amazonaws.com user=eqtzntsvypvmvr password=sth_vTghUKk5vSMPss1nIq8yzv port=5432"
-- Colocar os dados de acordo com o seu banco de dados.

main::IO()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
       runSqlPersistMPool (runMigration migrateAll) pool
       warp 8080 (App pool)
       -- static@(Static settings) <- static "static" levantando co nfigurações do uso de arquivos estaticos