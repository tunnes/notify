import Application () -- for YesodDispatch instance
import Foundation
import Yesod.Core

main :: IO ()
main = warp 8080 App
